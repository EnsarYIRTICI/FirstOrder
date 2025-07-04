. "$PSScriptRoot\IO.ps1"
. "$PSScriptRoot\Windows.System.ps1"
. "$PSScriptRoot\Windows.Network.ps1"

function Network-Settings {
    if ($IsWindows) {
        Detect-WindowsVersion

        $json = Get-SettingsJSON

        Write-Host "`nWindows Ağ Ayarları" -ForegroundColor Green

        if (Ask-YesNo "DNS ayarlansın mı ?") { Set-DNS }
        if (Ask-YesNo "Full-Tunnel kaldırılsın mı ?") { Remove-FullTunnel }

    }
    elseif ($IsLinux) {
        Write-Host "`nLinux Ağ Ayarları" -ForegroundColor Green
        Write-Host "`nLinux Ağ Ayarları Bulunamadı" -ForegroundColor Red

    }
    elseif ($IsMacOS) {
        Write-Host "`nMacOS Ağ Ayarları" -ForegroundColor Green
        Write-Host "`nMacOS Ağ Ayarları Bulunamadı" -ForegroundColor Red

    }
    else {
        Write-Host "Desteklenmeyen işletim Sistemi." -ForegroundColor Red

    }
}