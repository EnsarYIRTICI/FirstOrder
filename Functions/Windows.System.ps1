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

function Enable-HyperV {
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart -ErrorAction Stop | Out-Null
        Write-Host "Hyper-V etkinleştirildi. Değişikliklerin geçerli olması için sistemi yeniden başlatın."
    } catch {
        Write-Host "Hyper-V etkinleştirilemedi: $_"
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

function Enable-DeveloperMode {
    try {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
        Write-Host "Geliştirici Modu etkinleştirildi."
    } catch {
        Write-Host "Geliştirici Modu etkinleştirme başarısız oldu: $_"
    }
}

function Create-GuestUser {
    try {
        $userExists = Get-LocalUser -Name "misafir" -ErrorAction SilentlyContinue
        if ($null -eq $userExists) {
            New-LocalUser -Name "misafir" -Password (ConvertTo-SecureString "1453" -AsPlainText -Force) -FullName "Misafir" -Description "Misafir kullanıcı hesabı" | Out-Null
            Add-LocalGroupMember -Group "Users" -Member "misafir" | Out-Null
            Write-Host "'misafir' kullanıcısı başarıyla oluşturuldu."
        } else {
            Write-Host "'misafir' kullanıcısı zaten mevcut."
        }
    } catch {
        Write-Host "'Misafir' kullanıcısı oluşturulurken bir hata oluştu: $_"
    }
}

