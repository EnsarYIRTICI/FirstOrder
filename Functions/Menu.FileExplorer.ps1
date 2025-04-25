. "$PSScriptRoot\Windows.FileExplorer.ps1"

function FileExplorer-Settings {
    if ($IsWindows){

        Detect-WindowsVersion
        
        # Windows için dosya gezgini ayarları
        Write-Host "`nWindows Dosya Gezgini Ayarları" -ForegroundColor Green

        if (Ask-YesNo "Dosya uzantılarını görünür yapmak ister misin?") { Show-FileExtensions }
        if (Ask-YesNo "Gizli dosya ve klasörleri göstermek ister misin?") { Show-HiddenItems }
        if (Ask-YesNo "Dosya Gezgini'nde son kullanılan dosyaları gizlemek ister misin?") { Disable-RecentFiles }
        if (Ask-YesNo "Dosya Gezgini'nde sık kullanılan klasörleri gizlemek ister misin?") { Disable-FrequentFolders }

    }
    elseif ($IsLinux) {
        # Linux için dosya gezgini ayarları
        Write-Host "`nLinux Dosya Gezgini Ayarları" -ForegroundColor Green
        Write-Host "`nLinux Dosya Gezgini Ayarları Bulunamadı" -ForegroundColor Red

    }
    elseif ($IsMacOS) {
        # MacOS için dosya gezgini ayarları
        Write-Host "`nMacOS Dosya Gezgini Ayarları" -ForegroundColor Green
        Write-Host "`nMacOS Dosya Gezgini Ayarları Bulunamadı" -ForegroundColor Red

    } 
    else {
        Write-Host "Desteklenmeyen işletim sistemi." -ForegroundColor Red

    }
}