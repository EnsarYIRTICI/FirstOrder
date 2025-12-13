. "$scriptDir\Functions\Core\IO.ps1"
. "$scriptDir\Functions\Windows\System.ps1"

function System-Menu {
    if ($IsWindows) {
        Detect-WindowsVersion

        $json = Get-SettingsJSON

        Write-Host "`nWindows Sistem Ayarları" -ForegroundColor Green
        
        $newName = $json.computer_name

        if (Ask-YesNo "Bilgisayar adını '$newName' olarak değiştirmek istiyor musun?") { Rename-ComputerName -NewName $newName }
        if (Ask-YesNo "Windows Auto Update'i devre dışı bırakmak istiyor musun?") { Disable-WindowsAutoUpdate }
        if (Ask-YesNo "Geliştirici Modu etkinleştirilsin mi?") { Enable-DeveloperMode }
        if (Ask-YesNo "Administrator hesabını etkinleştirmek istiyor musun?") { Enable-AdministratorAccount }
        if (Ask-YesNo "OpenSSH etkinleştirilsin mi?") { Enable-OpenSSHServer }

        $username = $json.local_user.username

        if (Ask-YesNo "'$username' adında bir yerel kullanıcı oluşturmak istiyor musun?") { 
            Create-LocalUser -Username $username -Fullname $json.local_user.fullname -Password $json.local_user.password -Description $json.local_user.description
        } 
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