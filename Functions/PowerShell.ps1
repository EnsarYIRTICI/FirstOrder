. "$PSScriptRoot\Global.PowerShell.ps1"

function PowerShell-Settings {
    if (Ask-YesNo "PowerShell başlangıcında özel ayarları (profile) yüklemek istiyor musun?") { Set-Profile }
}
