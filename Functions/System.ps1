. "$PSScriptRoot\Windows.System.ps1"
. "$PSScriptRoot\IO.ps1"

function System-Settings {
    if ($IsWindows) {
        Detect-WindowsVersion

        Write-Host "`nWindows Sistem Ayarları" -ForegroundColor Green

        $json = Get-SettingsJSON
        $newName = $json.computer_name

        if (Ask-YesNo "Bilgisayar adını '$newName' olarak değiştirmek istiyor musun?") { Rename-ComputerName -NewName $newName }
        if (Ask-YesNo "Windows Update'i devre dışı bırakmak istiyor musun?") { Disable-WindowsUpdate }
        if (Ask-YesNo "Geliştirici Modu etkinleştirilsin mi?") { Enable-DeveloperMode }

        $username = $json.local_user.username

        if (Ask-YesNo "'$username' adında bir yerel kullanıcı oluşturmak istiyor musun?") { 
            Create-LocalUser -Username $username -Fullname $json.local_user.fullname -Password $json.local_user.password -Description $json.local_user.description
        }

        if (Ask-YesNo "WSL etkinleştirilsin mi?") { Enable-WSL }
        if (Ask-YesNo ".wslconfig ayarlansın mı?") { Create-WslConfig }

        if (Ask-YesNo "Hyper-V etkinleştirilsin mi?") { Enable-HyperV }
        if (Ask-YesNo "OpenSSH etkinleştirilsin mi?") { Enable-OpenSSHServer }

    }
    elseif ($IsLinux) {
        Write-Host "`nLinux Sistem Ayarları" -ForegroundColor Green
        Write-Host "`nLinux Sistem Ayarları Bulunamadı" -ForegroundColor Red


    }
    elseif ($IsMacOS) {
        Write-Host "`nMacOS Sistem Ayarları" -ForegroundColor Green
        Write-Host "`nMacOS Sistem Ayarları Bulunamadı" -ForegroundColor Red

    }
    else {
        Write-Host "Desteklenmeyen işletim sistemi." -ForegroundColor Red

    }
}