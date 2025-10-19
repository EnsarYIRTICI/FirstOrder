. "$scriptDir\Functions\Windows\FileExplorer.ps1"
. "$scriptDir\Functions\MacOS\Finder.ps1"

function FileExplorer-Menu {
    if ($IsWindows){

        Detect-WindowsVersion
        
        # Windows için dosya gezgini ayarları
        Write-Host "`nWindows Dosya Gezgini Ayarları" -ForegroundColor Green

        if (Ask-YesNo "Dosya uzantılarını görünür yapmak ister misin?") { Show-FileExtensions }
        if (Ask-YesNo "Gizli dosya ve klasörleri göstermek ister misin?") { Show-HiddenItems }
        if (Ask-YesNo "Dosya Gezgini'nde son kullanılan dosyaları gizlemek ister misin?") { Disable-RecentFiles }
        if (Ask-YesNo "Dosya Gezgini'nde sık kullanılan klasörleri gizlemek ister misin?") { Disable-FrequentFolders }
        if (Ask-YesNo "Dosya Gezginini yeniden başlatmak ister misin?") { Restart-Explorer }

    }
    elseif ($IsLinux) {
        # Linux için dosya gezgini ayarları
        Write-Host "`nLinux Dosya Gezgini Ayarları" -ForegroundColor Green
        Write-Host "`nLinux Dosya Gezgini Ayarları Bulunamadı" -ForegroundColor Red

    }
    elseif ($IsMacOS) {
        # MacOS için dosya gezgini ayarları
        Write-Host "`nMacOS Finder Ayarları" -ForegroundColor Green

        Write-Host "`nGizli dosyalar için seçenekler:" -ForegroundColor Cyan
        Write-Host "1. Gizli dosyaları göster" -ForegroundColor White
        Write-Host "2. Gizli dosyaları gizle" -ForegroundColor White
        Write-Host "3. Geçiş yap (göster/gizle)" -ForegroundColor White

        $choice = Read-Host "`nSeçiminiz (1-3, Enter = atla)"

        switch ($choice) {
            "1" { Show-HiddenFiles }
            "2" { Hide-HiddenFiles }
            "3" { Toggle-HiddenFiles }
            default { Write-Host "Atlandı." -ForegroundColor Yellow }
        }

    } 
    else {
        Write-Host "Desteklenmeyen işletim sistemi." -ForegroundColor Red

    }
}