# Menus\OpenSSH-Menu.ps1
. "$scriptDir\Functions\Core\IO.ps1"
. "$scriptDir\Functions\Windows\OpenSSH.ps1"
. "$scriptDir\Components\Show-Menu.ps1"

function OpenSSH-Menu {
    if (-not $IsWindows) {
        Write-Host "`nOpenSSH menüsü şu anda sadece Windows için tanımlı." -ForegroundColor Red
        return
    }

    $menuItems = @(
        @{ Label = "OpenSSH Server Etkinleştir"; Action = { Enable-OpenSSHServer } }
    )

    Show-Menu -MenuItems $menuItems -Title "OpenSSH Menü"
}