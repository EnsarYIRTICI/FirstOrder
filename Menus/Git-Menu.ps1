. "$scriptDir\Functions\Core\Git.ps1"

function Git-Menu {

    if ($IsWindows){
        Write-Host "`nWindows Git Ayarları" -ForegroundColor Green

        $gitInstalled = Check-GitInstalled

        if (-not $gitInstalled) {
            if (Ask-YesNo "Git yüklü değil. Chocolatey ile yüklemek ister misiniz?") { Install-GitWithChoco }
        }

        if ($gitInstalled) {
            if (Ask-YesNo "Git kullanıcı adı ve e-posta ayarlarını yapalım mı?") { Set-GitGlobalConfig }
        }

    } 
    elseif ($IsLinux) {
        Write-Host "`nLinux Git Ayarları" -ForegroundColor Green
        Write-Host "`nLinux Git Ayarları Bulunamadı" -ForegroundColor Red

 
    } 
    elseif ($IsMacOS) {
        Write-Host "`nMacOS Git Ayarları" -ForegroundColor Green
        Write-Host "`nMacOS Git Ayarları Bulunamadı" -ForegroundColor Red

    } else {
        Write-Host "Desteklenmeyen işletim sistemi." -ForegroundColor Red
        
    }

}