function Set-SearchBoxIcon {
    if ($isWindows) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
            Write-Host "Arama kutusu yalnızca simge olarak ayarlandı."
        } catch {
            Write-Host "Arama kutusu simge olarak gösterilirken bir hata oluştu: $_"
        }
    }
}

function Hide-TaskViewButton {
    if ($isWindows) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
            Write-Host "Görev Görünümü simgesi başarıyla gizlendi."
        } catch {
            Write-Host "Görev Görünümü simgesi gizlenirken bir hata oluştu: $_"
        }
    }
}

function Set-DarkMode {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
        Write-Host "Uygulama ve sistem teması başarıyla karanlık moda geçirildi."
    } catch {
        Write-Host "Bir hata oluştu: $_"
    }
}

function Add-DesktopIcons {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Value 0
        Write-Host "'Bu Bilgisayar' ve 'Denetim Masası' simgeleri başarıyla masaüstüne eklendi."
    } catch {
        Write-Host "Simgeler eklenirken bir hata oluştu: $_"
    }
}

function Align-TaskbarLeft {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
        Write-Host "Görev çubuğu simgeleri sola hizalandı."
    } catch {
        Write-Host "Görev çubuğu simgeleri sola hizalanırken bir hata oluştu: $_"
    }
}

function Disable-Widgets {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        New-ItemProperty -Path $regPath -Name "AllowNewsAndInterests" -PropertyType DWord -Value 0 -Force | Out-Null
        Write-Host "'Pencere Öğeleri' özelliği tamamen devre dışı bırakıldı."
    } catch {
        Write-Host "'Pencere Öğeleri' devre dışı bırakılırken bir hata oluştu: $_"
    }
}

function Enable-ClassicContextMenu {
    try {
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force | Out-Null
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -Force | Out-Null
        New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -PropertyType String -Force | Out-Null
        Write-Host "Klasik sağ tık menüsü geri getirildi."
    } catch {
        Write-Host "Klasik sağ tık menüsü getirilirken bir hata oluştu: $_"
    }
}

function Hide-News {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        New-ItemProperty -Path $regPath -Name "EnableFeeds" -PropertyType DWord -Value 0 -Force | Out-Null
        Write-Host "'Haberler ve İlgi Alanları' görev çubuğundan gizlendi."
    } catch {
        Write-Host "'Haberler ve İlgi Alanları' devre dışı bırakılırken bir hata oluştu: $_"
    }
}

function Disable-SleepTimeout {
    Write-Host "Bilgisayarın uykuya geçme süreleri ayarlanıyor..."
    
    # Prize takılıyken: hiçbir zaman uykuya geçmesin
    powercfg /change standby-timeout-ac 0

    # Pildeyken: 30 dakika (30 dakika = 30 dakika)
    powercfg /change standby-timeout-dc 30

    Write-Host "Uyku modu zaman aşımı başarıyla güncellendi:"
    Write-Host "- Prize takılıyken: Hiçbir zaman"
    Write-Host "- Pildeyken: 30 dakika"
}

function Set-LidCloseDoNothing {
    Write-Host "Kapak kapatıldığında prizdeyken hiçbir şey yapılmaması için ayarlanıyor..."
    
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LidAction 0
    powercfg /setactive SCHEME_CURRENT

    Write-Host "Ayar tamamlandı: Kapak kapatıldığında (prizdeyken) hiçbir şey yapılmayacak."
}