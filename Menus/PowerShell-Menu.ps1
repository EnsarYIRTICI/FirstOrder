. "$scriptDir\Functions\Core\PowerShell.ps1"

function PowerShell-Menu {
    if (Ask-YesNo "PowerShell başlangıcında özel ayarları (profile) yüklemek istiyor musun?") { Set-Profile }
}
