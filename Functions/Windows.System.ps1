. "$PSScriptRoot\IO.ps1"

function Detect-WindowsVersion {
    $version = [System.Environment]::OSVersion.Version
    $global:windowsVersion = 0
    $global:isWin10 = $false
    $global:isWin11 = $false

    if ($version.Major -eq 10) {
        if ($version.Build -lt 22000) {
            $global:windowsVersion = 10
            $global:isWin10 = $true
        } elseif ($version.Build -ge 22000) {
            $global:windowsVersion = 11
            $global:isWin11 = $true
        }
    }
}


function Rename-ComputerName {
    param (
        [string]$NewName
    )

    try {
        # Bilgisayar adı uzunluğu kontrolü
        if ($NewName.Length -gt 15) {
            Write-Host "Hata: Bilgisayar adı 15 karakterden uzun olamaz." -ForegroundColor Red
            return
        }

        # Geçerli karakter kontrolü: yalnızca harf, rakam ve tire
        if ($NewName -notmatch '^[a-zA-Z0-9\-]+$') {
            Write-Host "Hata: Bilgisayar adı yalnızca harf, rakam ve tire içerebilir." -ForegroundColor Red
            return
        }

        Rename-Computer -NewName $NewName -Force

        Write-Host "Bilgisayar adı başarıyla '$NewName' olarak değiştirildi." -ForegroundColor Green
    } catch {
        Write-Host "Hata oluştu: $_" -ForegroundColor Red
    }
}


function Disable-WindowsUpdate {
    try {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Force | Out-Null
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1 -PropertyType DWORD -Force | Out-Null
        Write-Host "Windows Update devre dışı bırakıldı."
    } catch {
        Write-Host "Windows Update devre dışı bırakılırken bir hata oluştu: $_"
    }
}


function Create-LocalUser {
    param (
        [string]$Fullname = "Misafir",
        [string]$Username = "misafir",
        [string]$Password = "1453",
        [string]$Description = "Misafir Kullanıcı"
    )

    try {
        $userExists = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
        if ($null -eq $userExists) {
            New-LocalUser -Name $Username -Password (ConvertTo-SecureString $Password -AsPlainText -Force) -FullName $Fullname -Description $Description | Out-Null
            Add-LocalGroupMember -Group "Users" -Member $Username | Out-Null
            Write-Host "'$Username' kullanıcısı başarıyla oluşturuldu."
        } else {
            Write-Host "'$Username' kullanıcısı zaten mevcut."
        }
    } catch {
        Write-Host "'$Username' kullanıcısı oluşturulurken bir hata oluştu: $_"
    }
}


function Enable-DeveloperMode {
    try {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
        Write-Host "Geliştirici Modu etkinleştirildi."
    } catch {
        Write-Host "Geliştirici Modu etkinleştirme başarısız oldu: $_"
    }
}

function Enable-WSL {
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart -ErrorAction Stop | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart -ErrorAction Stop | Out-Null

        Write-Host "WSL etkinleştirildi. WSL çekirdeği güncelleniyor..."
        wsl --update
        Write-Host "WSL çekirdeği kuruldu. Sisteminizi yeniden başlatmanız gerekebilir."
    } catch {
        Write-Host "WSL etkinleştirme sırasında bir hata oluştu: $_"
    }
}


function Create-WslConfig {
    try {
        $wslconfigPath = "$env:USERPROFILE\.wslconfig"

        $json = Get-SettingsJSON
        $wslConfig = $json.wsl_config

        $lines = @()

        # wsl2 bölümü
        if ($wslConfig.PSObject.Properties.Name -contains "wsl2") {
            $lines += "[wsl2]"
            foreach ($prop in $wslConfig.wsl2.PSObject.Properties) {
                $lines += "$($prop.Name)=$($prop.Value)"
            }
            $lines += ""
        }

        # network bölümü
        if ($wslConfig.PSObject.Properties.Name -contains "network") {
            $lines += "[network]"
            foreach ($prop in $wslConfig.network.PSObject.Properties) {
                $val = $prop.Value
                # true/false'ları lowercase yazalım
                if ($val -is [bool]) {
                    $val = $val.ToString().ToLower()
                }
                $lines += "$($prop.Name)=$val"
            }
        }

        $lines -join "`r`n" | Set-Content -Path $wslconfigPath -Encoding UTF8

        Write-Host ".wslconfig başarıyla oluşturuldu." -ForegroundColor Cyan
    } catch {
        Write-Host "Hata: $_" -ForegroundColor Red
    }
}




function Enable-HyperV {
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart -ErrorAction Stop | Out-Null
        Write-Host "Hyper-V etkinleştirildi. Değişikliklerin geçerli olması için sistemi yeniden başlatın."
    } catch {
        Write-Host "Hyper-V etkinleştirilemedi: $_"
    }
}

function Enable-OpenSSHServer {
    try {
        # Özelliği etkinleştir
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop | Out-Null

        # Servisi başlat ve otomatik başlatma moduna ayarla
        Start-Service sshd
        Set-Service -Name sshd -StartupType 'Automatic'

        Write-Host "OpenSSH Server başarıyla etkinleştirildi ve başlatıldı." -ForegroundColor Green
    } catch {
        Write-Host "OpenSSH Server etkinleştirilirken bir hata oluştu: $_" -ForegroundColor Red
    }
}