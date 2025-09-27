. "$scriptDir\Functions\Core\Git.ps1"
. "$scriptDir\Functions\Core\Vscode.ps1"

function Vscode-Menu{

    if ($IsWindows){
        Write-Host "`nWindows Git Ayarları" -ForegroundColor Green

        $vscodeInstalled = Check-ChocoInstalled

        if (-not $vscodeInstalled) {
            if (Ask-YesNo "Visual Studio Code yüklü değil. Chocolatey ile yüklemek ister misiniz?") { Install-VscodeWithChoco }
        }

        if ($vscodeInstalled) {
            if (Ask-YesNo "'Vscode İle Aç' Eklensin mi ?") { Add-VscodeOpenWith }
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