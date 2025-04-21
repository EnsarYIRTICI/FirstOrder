# == Başlangıç ==
Write-Host "Script Başlatılıyor..." -ForegroundColor Green

# == Mevcut Dizin ==
$scriptDir = $PSScriptRoot

# == Temel Import Modülleri ==
. "$PSScriptRoot\Functions\Guard.ps1"

# == İşletim Sistemi ==
Detect-OS

# == Tam Yetki Kontrolü ==
Assert-AdminRights

# == Import Modülleri ==
. "$PSScriptRoot\Functions\IO.ps1"
. "$PSScriptRoot\Functions\System.ps1"
. "$PSScriptRoot\Functions\Personalize.ps1"
. "$PSScriptRoot\Functions\Package.ps1"
. "$PSScriptRoot\Functions\FileExplorer.ps1"

# == ANA SEÇİM MENÜSÜ ==
do {
    Write-Host "`nNe yapmak istiyorsunuz?" -ForegroundColor Cyan
    Write-Host "1. Sistem Ayarlarını Yapılandır"
    Write-Host "2. Kişiselleştirme Ayarlarını Yapılandır"
    Write-Host "3. Dosya Gezgini Ayarlarını Yapılandır"
    Write-Host "4. Paket Yönetimi ile Yazılım Kurulumu"
    Write-Host "Q. Çıkış"
    $mainChoice = Read-Host "Seçiminiz (1-4, Q)"

    switch ($mainChoice.ToUpper()) {
        "1" {
            System-Settings
        }
        "2" {
            Personalize-Settings
        }
        "3" {
            FileExplorer-Settings
        }
        "4" {
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
