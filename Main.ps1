# == Başlangıç ==
Write-Host "Script Başlatılıyor..." -ForegroundColor Green

# == Mevcut Dizin ==
$scriptDir = $PSScriptRoot

# == Temel Import Modülleri ==
. "$scriptDir\Functions\Core\Guard.ps1"
. "$scriptDir\Functions\Core\IO.ps1"

# == Bileşen Importları ==
. "$scriptDir\Components\Show-Menu.ps1"

# == settings.json Kontrolü ==
Check-SettingsJSON

# == İşletim Sistemi ==
Detect-OS

# == Tam Yetki Kontrolü ==
Assert-AdminRights

# == Import Modülleri ==
. "$scriptDir\Menus\System-Menu.ps1"
. "$scriptDir\Menus\Personalize-Menu.ps1"
. "$scriptDir\Menus\FileExplorer-Menu.ps1"
. "$scriptDir\Menus\Package-Menu.ps1"
. "$scriptDir\Menus\Git-Menu.ps1"
. "$scriptDir\Menus\Vscode-Menu.ps1"
. "$scriptDir\Menus\Android-Menu.ps1"
. "$scriptDir\Menus\PowerShell-Menu.ps1"
. "$scriptDir\Menus\WSL-Menu.ps1"
. "$scriptDir\Menus\HyperV-Menu.ps1"

# == Menü Tanımı ==
$menuItems = @(
    @{ Label = "Sistem"; Action = { System-Menu } },
    @{ Label = "Kişiselleştirme"; Action = { Personalize-Menu } },
    @{ Label = "Dosya Gezgini"; Action = { FileExplorer-Menu } },
    @{ Label = "Paket Yönetimi"; Action = { Package-Menu } },
    @{ Label = "Git"; Action = { Git-Menu } }
    @{ Label = "Vscode"; Action = { Vscode-Menu } }
    @{ Label = "Android"; Action = { Android-Menu } }
    @{ Label = "PowerShell"; Action = { PowerShell-Menu } },
    @{ Label = "WSL"; Action = { WSL-Menu } },
    @{ Label = "Hyper-V"; Action = { HyperV-Menu } }
)

Show-Menu -MenuItems $menuItems -Title "Ana Menü" # -ClearOnEachLoop # -PauseAfterAction
