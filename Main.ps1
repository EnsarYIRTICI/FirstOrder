# == Başlangıç ==
Write-Host "Script Başlatılıyor..." -ForegroundColor Green

# == Mevcut Dizin ==
$scriptDir = $PSScriptRoot

# == Temel Import Modülleri ==
. "$scriptDir\Functions\Guard.ps1"

# == İşletim Sistemi ==
Detect-OS

# == Tam Yetki Kontrolü ==
Assert-AdminRights

# == Import Modülleri ==
. "$scriptDir\Functions\Menu.System.ps1"
. "$scriptDir\Functions\Menu.Personalize.ps1"
. "$scriptDir\Functions\Menu.Package.ps1"
. "$scriptDir\Functions\Menu.FileExplorer.ps1"
. "$scriptDir\Functions\Menu.PowerShell.ps1"
. "$scriptDir\Functions\Menu.Git.ps1"
. "$scriptDir\Functions\Menu.Vscode.ps1"

# == Menü Tanımı ==
$menuItems = @(
    @{ Label = "Sistem"; Action = { System-Settings } },
    @{ Label = "Kişiselleştirme"; Action = { Personalize-Settings } },
    @{ Label = "Dosya Gezgini"; Action = { FileExplorer-Settings } },
    @{ Label = "Paket Yönetimi"; Action = { Install-Packages } },
    @{ Label = "PowerShell"; Action = { PowerShell-Settings } },
    @{ Label = "Git"; Action = { Git-Settings } }
    @{ Label = "Vscode"; Action = { Vscode-Settings } }
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
                & $action
            } else {
                Write-Host "Geçersiz seçim yapıldı, lütfen tekrar deneyin." -ForegroundColor Red
            }
        }
    }
} while ($mainChoice.ToUpper() -ne "Q")
