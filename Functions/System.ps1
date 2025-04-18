. "$PSScriptRoot\Windows.System.ps1"

function System-Settings {
    if ($IsWindows) {
        Write-Host "`nWindows Sistem Ayarları" -ForegroundColor Green
        if (Ask-YesNo "Windows Update'i devre dışı bırakmak istiyor musun?") { Disable-WindowsUpdate }
        if (Ask-YesNo "Geliştirici Modu etkinleştirilsin mi?") { Enable-DeveloperMode }
        if (Ask-YesNo "WSL etkinleştirilsin ve kurulsun mu?") { Enable-WSL }
        if (Ask-YesNo "Hyper-V etkinleştirilsin mi?") { Enable-HyperV }
        if (Ask-YesNo "'misafir' adında bir misafir kullanıcı oluşturmak istiyor musun?") { Create-GuestUser }

    }
    elseif ($IsLinux) {
        Write-Host "`nLinux Sistem Ayarları" -ForegroundColor Green

    }
    elseif ($IsMacOS) {
        Write-Host "`nMacOS Sistem Ayarları" -ForegroundColor Green

    }
}