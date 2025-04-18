# == Başlangıç ==
Write-Host "Script Başlatılıyor..." -ForegroundColor Green

# == Mevcut Dizin ==
$scriptDir = $PSScriptRoot

# == İşletim Sistemi ==
if (-not ($IsWindows -or $IsLinux -or $IsMacOS)) {
    $IsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
    $IsLinux = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)
    $IsMacOS = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)
}

# == Import Modülleri ==
. "$PSScriptRoot\Functions\IO.ps1"
. "$PSScriptRoot\Functions\Guard.ps1"
. "$PSScriptRoot\Functions\System.ps1"
. "$PSScriptRoot\Functions\Personalize.ps1"
. "$PSScriptRoot\Functions\Package.ps1"

# == Tam Yetki Kontrolü ==
Assert-AdminRights

# == ANA SEÇİM MENÜSÜ ==
do {
    Write-Host "`nNe yapmak istiyorsunuz?" -ForegroundColor Cyan
    Write-Host "1. Sistem Ayarlarını Yapılandır"
    Write-Host "2. Kişiselleştirme Ayarlarını Yapılandır"
    Write-Host "3. Paket Yönetimi ile Yazılım Kurulumu"
    Write-Host "Q. Çıkış"
    $mainChoice = Read-Host "Seçiminiz (1-3, Q)"

    switch ($mainChoice.ToUpper()) {
        "1" {
            System-Settings
        }
        "2" {
            Personalize-Settings
        }
        "3" {
            Install-Packages
        }
        "Q" {
            Write-Host "Çıkılıyor..." -ForegroundColor Yellow
        }
        default {
            Write-Host "Geçersiz seçim yapıldı, lütfen tekrar deneyin." -ForegroundColor Red
        }
    }
} while ($mainChoice.ToUpper() -ne "Q")
