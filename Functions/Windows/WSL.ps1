. "$PSScriptRoot\..\Core\IO.ps1"

function Get-WSLStatus {
    $wslCmd = Get-Command wsl -ErrorAction SilentlyContinue
    if (-not $wslCmd) {
        return [pscustomobject]@{
            WslCommand = $false
            WslFeature = $null
            VmPlatform = $null
            DefaultVersion = $null
        }
    }

    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
    $vmPlatform = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue

    $defaultVer = $null
    try {
        $out = (wsl --status) 2>$null
        $m = $out | Select-String -Pattern "Default Version:\s*(\d+)" -AllMatches
        if ($m) { $defaultVer = $m.Matches[0].Groups[1].Value }
    } catch {}

    [pscustomobject]@{
        WslCommand = $true
        WslFeature = $wslFeature.State
        VmPlatform = $vmPlatform.State
        DefaultVersion = $defaultVer
    }
}

function Enable-WSL {
    try {
        Write-Host "WSL etkinleştiriliyor..." -ForegroundColor Cyan
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart -ErrorAction Stop | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart -ErrorAction Stop | Out-Null
        Write-Host "✔️ WSL ve VirtualMachinePlatform etkinleştirildi (restart gerekebilir)." -ForegroundColor Green
    } catch {
        Write-Host "❌ WSL etkinleştirme hatası: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Disable-WSL {
    try {
        Write-Host "WSL devre dışı bırakılıyor..." -ForegroundColor Yellow
        Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop | Out-Null
        Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop | Out-Null
        Write-Host "✔️ WSL ve VirtualMachinePlatform kapatıldı (restart gerekebilir)." -ForegroundColor Green
    } catch {
        Write-Host "❌ WSL kapatma hatası: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Update-WSLKernel {
    try {
        Write-Host "WSL kernel güncelleniyor..." -ForegroundColor Cyan
        wsl --update
        Write-Host "✔️ WSL kernel update komutu çalıştı." -ForegroundColor Green
    } catch {
        Write-Host "❌ WSL update hatası: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Set-WSLDefaultVersion {
    param([ValidateSet(1,2)][int]$Version = 2)

    try {
        wsl --set-default-version $Version
        Write-Host "✔️ Default WSL version = $Version" -ForegroundColor Green
    } catch {
        Write-Host "❌ Default version set hatası: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-WSLDistros {
    try {
        Write-Host "`n=== WSL Distro Listesi ===" -ForegroundColor Green
        wsl -l -v
    } catch {
        Write-Host "❌ Distro listeleme hatası: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Shutdown-WSL {
    try {
        wsl --shutdown
        Write-Host "✔️ WSL kapatıldı (shutdown)." -ForegroundColor Green
    } catch {
        Write-Host "❌ WSL shutdown hatası: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Create-WslConfig {
    try {
        $wslconfigPath = "$env:USERPROFILE\.wslconfig"

        $json = Get-SettingsJSON
        $wslConfig = $json.wsl_config
        if (-not $wslConfig) {
            Write-Host "⚠️ settings.json içinde 'wsl_config' yok. settings.example.json'dan ekleyebilirsin." -ForegroundColor Yellow
            return
        }

        $lines = @()

        if ($wslConfig.PSObject.Properties.Name -contains "wsl2") {
            $lines += "[wsl2]"
            foreach ($prop in $wslConfig.wsl2.PSObject.Properties) {
                $lines += "$($prop.Name)=$($prop.Value)"
            }
            $lines += ""
        }

        if ($wslConfig.PSObject.Properties.Name -contains "network") {
            $lines += "[network]"
            foreach ($prop in $wslConfig.network.PSObject.Properties) {
                $val = $prop.Value
                if ($val -is [bool]) { $val = $val.ToString().ToLower() }
                $lines += "$($prop.Name)=$val"
            }
        }

        $lines -join "`r`n" | Set-Content -Path $wslconfigPath -Encoding UTF8
        Write-Host "✔️ .wslconfig yazıldı: $wslconfigPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ .wslconfig hatası: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Open-WslConfig {
    $path = "$env:USERPROFILE\.wslconfig"
    if (Test-Path $path) {
        notepad $path
    } else {
        Write-Host "⚠️ .wslconfig yok: $path (önce oluştur)" -ForegroundColor Yellow
    }
}
