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

function Set-SingleClickOpen {
    [CmdletBinding()]
    param ()

    $ShellState = [byte[]](
        0x24, 0x00, 0x00, 0x00, 0x1E, 0xA8, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
        0x13, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x62, 0x00, 0x00, 0x00
    )

    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShellState" -Value $ShellState -Force
        Write-Host "Tek tıkla açma modu başarıyla ayarlandı. Explorer yeniden başlatılıyor..." -ForegroundColor Green
        
        Stop-Process -Name explorer -Force
    }
    catch {
        Write-Error "Bir hata oluştu: $_"
    }
}

function Restart-Explorer {
    [CmdletBinding()]
    param ()

    try {
        Write-Host "Explorer yeniden başlatılıyor..." -ForegroundColor Yellow

        Stop-Process -Name explorer -Force 

        Write-Host "Explorer başarıyla yeniden başlatıldı." -ForegroundColor Green
    }
    catch {
        Write-Error "Explorer'ı yeniden başlatırken hata oluştu: $_"
    }
}
