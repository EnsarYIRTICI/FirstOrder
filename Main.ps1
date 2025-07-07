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

# == Menü Tanımı ==
$menuItems = @(
    @{ Label = "Sistem"; Action = { System-Settings } },
    @{ Label = "Kişiselleştirme"; Action = { Personalize-Settings } },
    @{ Label = "Dosya Gezgini"; Action = { FileExplorer-Settings } },
    @{ Label = "Paket Yönetimi"; Action = { Install-Packages } },
    @{ Label = "PowerShell"; Action = { PowerShell-Settings } },
    @{ Label = "Git"; Action = { Git-Settings } }
)

# == Ana Menü Döngüsü ==
do {
    Write-Host "`nNe yapmak istiyorsunuz?" -ForegroundColor Cyan

    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        Write-Host "$($i + 1). $($menuItems[$i].Label)"
    }
    Write-Host "Q. Çıkış"

    $mainChoice = Read-Host "Seçiminiz (1-$($menuItems.Count), Q)"

    switch ($mainChoice.ToUpper()) {
        "Q" {
            Write-Host "Çıkılıyor..." -ForegroundColor Yellow
        }
        default {
            if ($mainChoice -as [int] -and $mainChoice -ge 1 -and $mainChoice -le $menuItems.Count) {
                $action = $menuItems[$mainChoice - 1].Action
                & $action.Invoke()
            } else {
                Write-Host "Geçersiz seçim yapıldı, lütfen tekrar deneyin." -ForegroundColor Red
            }
        }
    }
} while ($mainChoice.ToUpper() -ne "Q")
