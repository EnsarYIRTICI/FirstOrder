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
. "$PSScriptRoot\Functions\Menu.System.ps1"
. "$PSScriptRoot\Functions\Menu.Personalize.ps1"
. "$PSScriptRoot\Functions\Menu.Package.ps1"
. "$PSScriptRoot\Functions\Menu.FileExplorer.ps1"
. "$PSScriptRoot\Functions\Menu.PowerShell.ps1"
. "$PSScriptRoot\Functions\Menu.Git.ps1"
. "$PSScriptRoot\Functions\Menu.Network.ps1"

# == ANA SEÇİM MENÜSÜ ==
do {
    Write-Host "`nNe yapmak istiyorsunuz?" -ForegroundColor Cyan
    Write-Host "1. Sistem"
    Write-Host "2. Kişiselleştirme"
    Write-Host "3. Dosya Gezgini"
    Write-Host "4. Ağ"
    Write-Host "5. Paket Yönetimi"
    Write-Host "6. PowerShell"
    Write-Host "7. Git"
    Write-Host "Q. Çıkış"
    $mainChoice = Read-Host "Seçiminiz (1-7, Q)"

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
            Network-Settings
        }        
        "5" {
            Install-Packages
        }        
        "6" {
            PowerShell-Settings
        }
        "7" {
            Git-Settings
        }
        "Q" {
            Write-Host "Çıkılıyor..." -ForegroundColor Yellow
        }
        default {
            Write-Host "Geçersiz seçim yapıldı, lütfen tekrar deneyin." -ForegroundColor Red
        }
    }
} while ($mainChoice.ToUpper() -ne "Q")
