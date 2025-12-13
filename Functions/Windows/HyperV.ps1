# Functions/Windows/HyperV.ps1

function Resolve-HyperVFeatureName {
    $candidates = @(
        "Microsoft-Hyper-V-All",
        "Microsoft-Hyper-V"
    )

    foreach ($name in $candidates) {
        try {
            Get-WindowsOptionalFeature -Online -FeatureName $name -ErrorAction Stop | Out-Null
            return $name
        } catch { }
    }
    return $null
}

function Get-HyperVFeatureState {
    $name = Resolve-HyperVFeatureName
    if (-not $name) { return "NotFound" }

    try {
        return (Get-WindowsOptionalFeature -Online -FeatureName $name).State
    } catch {
        return "Unknown"
    }
}

function Get-HyperVManagementPowershellState {
    $name = "Microsoft-Hyper-V-Management-PowerShell"
    try {
        return (Get-WindowsOptionalFeature -Online -FeatureName $name -ErrorAction Stop).State
    } catch {
        return "NotFound"
    }
}

function Enable-HyperVFeature {
    $featureName = Resolve-HyperVFeatureName
    if (-not $featureName) {
        Write-Host "Hyper-V feature adı bulunamadı. Windows sürümünüz Hyper-V desteklemiyor olabilir." -ForegroundColor Red
        return
    }

    Write-Host "Hyper-V etkinleştiriliyor: $featureName" -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart | Out-Null

    # Yönetim PowerShell modülü (çoğu sistemde gerekebilir)
    try {
        Write-Host "Hyper-V PowerShell yönetim bileşeni etkinleştiriliyor..." -ForegroundColor Yellow
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Management-PowerShell" -All -NoRestart | Out-Null
    } catch { }

    Write-Host "İşlem tamamlandı. Hyper-V'nin tam çalışması için yeniden başlatma gerekebilir." -ForegroundColor Green
}

function Disable-HyperVFeature {
    $featureName = Resolve-HyperVFeatureName
    if (-not $featureName) {
        Write-Host "Hyper-V feature adı bulunamadı." -ForegroundColor Red
        return
    }

    Write-Host "Hyper-V devre dışı bırakılıyor: $featureName" -ForegroundColor Yellow
    Disable-WindowsOptionalFeature -Online -FeatureName $featureName -NoRestart | Out-Null
    Write-Host "İşlem tamamlandı. Yeniden başlatma gerekebilir." -ForegroundColor Green
}

function Ensure-HyperVModule {
    if (Get-Command Get-VMHost -ErrorAction SilentlyContinue) { return $true }
    try {
        Import-Module Hyper-V -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Show-HyperVStatus {
    $state = Get-HyperVFeatureState
    $psState = Get-HyperVManagementPowershellState

    Write-Host "`n=== Hyper-V Durumu ===" -ForegroundColor Cyan
    Write-Host ("Hyper-V Feature        : {0}" -f $state)
    Write-Host ("PowerShell Yönetim Modu: {0}" -f $psState)

    if ($state -ne "Enabled") {
        Write-Host "Not: Hyper-V etkin değilse 'Get-VMHost/Set-VMHost' çalışmayabilir." -ForegroundColor DarkYellow
    }
}

function Show-HyperVHostPaths {
    if (-not (Ensure-HyperVModule)) {
        Write-Host "Hyper-V PowerShell modülü yüklenemedi. Hyper-V etkinleştirilip yeniden başlatılmış olmalı." -ForegroundColor Red
        return
    }

    try {
        Write-Host "`n=== VMHost Varsayılan Yolları ===" -ForegroundColor Cyan
        Get-VMHost | Select-Object VirtualMachinePath, VirtualHardDiskPath | Format-List
    } catch {
        Write-Host "Get-VMHost çalıştırılamadı: $_" -ForegroundColor Red
    }
}

function Set-HyperVHostPaths {
    param(
        [Parameter(Mandatory)] [string] $VirtualMachinePath,
        [Parameter(Mandatory)] [string] $VirtualHardDiskPath
    )

    if (-not (Ensure-HyperVModule)) {
        Write-Host "Hyper-V PowerShell modülü yüklenemedi. Hyper-V etkinleştirilip yeniden başlatılmış olmalı." -ForegroundColor Red
        return
    }

    # klasörleri yoksa oluştur
    New-Item -ItemType Directory -Path $VirtualMachinePath -Force | Out-Null
    New-Item -ItemType Directory -Path $VirtualHardDiskPath -Force | Out-Null

    try {
        Set-VMHost -VirtualMachinePath $VirtualMachinePath -VirtualHardDiskPath $VirtualHardDiskPath | Out-Null
        Write-Host "Varsayılan yollar güncellendi." -ForegroundColor Green
        Show-HyperVHostPaths
    } catch {
        Write-Host "Set-VMHost başarısız: $_" -ForegroundColor Red
    }
}

function Set-HyperVHostPathsInteractive {
    $json = $null
    try { $json = Get-SettingsJSON } catch { }

    $defaultVm  = $json.hyperv.vm_path
    $defaultVhd = $json.hyperv.vhd_path

    Write-Host "`nVarsayılan VM/VHD yollarını ayarla" -ForegroundColor Cyan
    if (-not [string]::IsNullOrWhiteSpace($defaultVm))  { Write-Host "settings.json VM  : $defaultVm"  -ForegroundColor DarkGray }
    if (-not [string]::IsNullOrWhiteSpace($defaultVhd)) { Write-Host "settings.json VHD : $defaultVhd" -ForegroundColor DarkGray }

    $vmPath  = Read-Host "VirtualMachinePath (Enter: settings.json veya boşsa elle gir)"
    if ([string]::IsNullOrWhiteSpace($vmPath))  { $vmPath  = $defaultVm }

    $vhdPath = Read-Host "VirtualHardDiskPath (Enter: settings.json veya boşsa elle gir)"
    if ([string]::IsNullOrWhiteSpace($vhdPath)) { $vhdPath = $defaultVhd }

    if ([string]::IsNullOrWhiteSpace($vmPath) -or [string]::IsNullOrWhiteSpace($vhdPath)) {
        Write-Host "VM/VHD yolu boş olamaz." -ForegroundColor Red
        return
    }

    Set-HyperVHostPaths -VirtualMachinePath $vmPath -VirtualHardDiskPath $vhdPath
}
