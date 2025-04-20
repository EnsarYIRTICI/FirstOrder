function Show-FileExtensions {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
        Write-Host "Dosya uzantıları görünür hale getirildi ve Windows Gezgini yeniden başlatıldı."
    } catch {
        Write-Host "Dosya uzantılarını görünür yaparken bir hata oluştu: $_"
    }
}

function Show-HiddenItems {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
        Write-Host "Gizli dosya ve klasörler görünür hale getirildi ve Windows Gezgini yeniden başlatıldı."
    } catch {
        Write-Host "Gizli öğeleri gösterirken bir hata oluştu: $_"
    }
}

function Disable-RecentFiles {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0
        Write-Host "Son kullanılan dosyalar başarıyla gizlendi."
    } catch {
        Write-Host "Hata: Son kullanılan dosyalar gizlenemedi. $_" -ForegroundColor Red
    }
}

function Disable-FrequentFolders {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0
        Write-Host "Sık kullanılan klasörler başarıyla gizlendi."
    } catch {
        Write-Host "Hata: Sık kullanılan klasörler gizlenemedi. $_" -ForegroundColor Red
    }
}
