. "$scriptDir\Functions\Core\IO.ps1"

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


function Disable-WindowsAutoUpdate {
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

function Enable-AdministratorAccount {
    try {
        Write-Host "Yerleşik Administrator hesabı etkinleştiriliyor..." -ForegroundColor Yellow
        Enable-LocalUser -Name "Administrator"
        Write-Host "Administrator hesabı başarıyla etkinleştirildi." -ForegroundColor Green
    } catch {
        Write-Host "Administrator hesabı etkinleştirilirken bir hata oluştu: $_" -ForegroundColor Red
    }
}

function Is-DeveloperModeEnabled {
    try {
        $value = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction Stop
        return $value.AllowDevelopmentWithoutDevLicense -eq 1
    } catch {
        return $false
    }
}

