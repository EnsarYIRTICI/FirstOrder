. "$PSScriptRoot\IO.ps1"

function Install-ChocoPackages {
    param(
        [ValidateSet("common", "advanced")]
        [string]$Type = "common"
    )

    Write-Host "Chocolatey ile $Type yazılımlar kuruluyor..."

    $json = Get-SettingsJSON
    $chocoPackages = $json.packages.windows.$Type.chocolatey

    Write-Host "Kurulacak paketler: $chocoPackages"

    foreach ($pkg in $chocoPackages) {
        Write-Host "Kuruluyor: $pkg"
        choco install $pkg -y
    }
}

function Install-WingetPackages {
    param(
        [ValidateSet("common", "advanced")]
        [string]$Type = "common"
    )

    Write-Host "Winget ile $Type yazılımlar kuruluyor..."
    
    $json = Get-SettingsJSON
    $wingetPackages = $json.packages.windows.$Type.winget

    Write-Host "Kurulacak paketler: $wingetPackages"

    foreach ($pkg in $wingetPackages) {
        Write-Host "Kuruluyor: $pkg"
        winget install --id $pkg --accept-package-agreements --accept-source-agreements
    }
}

function Install-Chocolatey {
    if (-not $IsWindows) {
        Write-Host "Chocolatey sadece Windows sistemlerde kullanılabilir."
        return
    }

    Write-Host "Chocolatey kuruluyor..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    if ($?) {
        Write-Host "Chocolatey başarıyla kuruldu."
    } else {
        Write-Host "Chocolatey kurulumu başarısız oldu."
    }
}

function Install-Winget {
    if (-not $IsWindows) {
        Write-Host "Winget sadece Windows sistemlerde kullanılabilir."
        return
    }

    try {
        $ProgressPreference = 'SilentlyContinue'
        Write-Host "WinGet PowerShell modülü PSGallery üzerinden kuruluyor..."
        
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null

        Write-Host "WinGet modülü indirildi. Bootstrap işlemi başlatılıyor..."
        Repair-WinGetPackageManager

        Write-Host "WinGet bootstrap tamamlandı. Terminali yeniden başlatmanız gerekebilir."
    } catch {
        Write-Host "Winget kurulumu sırasında bir hata oluştu: $_"
    }
}

function Check-ChocoInstalled {
    $global:chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
    return $global:chocoInstalled -ne $null
}

function Check-WingetInstalled {
    $global:wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
    return $global:wingetInstalled -ne $null
}