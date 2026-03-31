function Set-RegistryDWORD {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWORD -Force | Out-Null
        return $true
    }
    catch {
        Write-Host "Registry ayarı uygulanamadı: $Name -> $_" -ForegroundColor Red
        return $false
    }
}

function Set-RegistryString {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value
    )

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType String -Force | Out-Null
        return $true
    }
    catch {
        Write-Host "Registry string ayarı uygulanamadı: $Name -> $_" -ForegroundColor Red
        return $false
    }
}

function Set-SearchBoxIcon {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
        Set-RegistryDWORD -Path $path -Name "SearchboxTaskbarMode" -Value 1 | Out-Null
        Write-Host "Arama kutusu yalnızca simge olarak ayarlandı." -ForegroundColor Green
    }
    catch {
        Write-Host "Arama kutusu simge olarak gösterilirken hata oluştu: $_" -ForegroundColor Red
    }
}

function Hide-TaskViewButton {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-RegistryDWORD -Path $path -Name "ShowTaskViewButton" -Value 0 | Out-Null
        Write-Host "Görev Görünümü simgesi başarıyla gizlendi." -ForegroundColor Green
    }
    catch {
        Write-Host "Görev Görünümü simgesi gizlenirken hata oluştu: $_" -ForegroundColor Red
    }
}

function Set-DarkMode {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-RegistryDWORD -Path $path -Name "AppsUseLightTheme" -Value 0 | Out-Null
        Set-RegistryDWORD -Path $path -Name "SystemUsesLightTheme" -Value 0 | Out-Null
        Write-Host "Uygulama ve sistem teması karanlık moda geçirildi." -ForegroundColor Green
    }
    catch {
        Write-Host "Karanlık mod uygulanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Add-DesktopIcons {
    $paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"
    )

    $icons = @(
        "{20D04FE0-3AEA-1069-A2D8-08002B30309D}", # Bu Bilgisayar
        "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"  # Denetim Masası
    )

    $success = $false

    foreach ($path in $paths) {
        try {
            if (-not (Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }

            foreach ($icon in $icons) {
                Set-RegistryDWORD -Path $path -Name $icon -Value 0 | Out-Null
            }

            $success = $true
        }
        catch {
            Write-Host "[$path] için masaüstü simgeleri eklenirken hata oluştu: $_" -ForegroundColor Red
        }
    }

    if ($success) {
        Write-Host "'Bu Bilgisayar' ve 'Denetim Masası' simgeleri masaüstüne eklendi." -ForegroundColor Green
    }
    else {
        Write-Host "Masaüstü simgeleri eklenemedi." -ForegroundColor Red
    }
}

function Align-TaskbarLeft {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-RegistryDWORD -Path $path -Name "TaskbarAl" -Value 0 | Out-Null
        Write-Host "Görev çubuğu simgeleri sola hizalandı." -ForegroundColor Green
    }
    catch {
        Write-Host "Görev çubuğu simgeleri sola hizalanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Disable-Widgets {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
        Set-RegistryDWORD -Path $regPath -Name "AllowNewsAndInterests" -Value 0 | Out-Null
        Write-Host "'Pencere Öğeleri' özelliği devre dışı bırakıldı." -ForegroundColor Green
    }
    catch {
        Write-Host "'Pencere Öğeleri' devre dışı bırakılırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Enable-ClassicContextMenu {
    try {
        $basePath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
        $subPath  = "$basePath\InprocServer32"

        if (-not (Test-Path $basePath)) {
            New-Item -Path $basePath -Force | Out-Null
        }

        if (-not (Test-Path $subPath)) {
            New-Item -Path $subPath -Force | Out-Null
        }

        Set-ItemProperty -Path $subPath -Name "(default)" -Value ""
        Write-Host "Klasik sağ tık menüsü geri getirildi." -ForegroundColor Green
    }
    catch {
        Write-Host "Klasik sağ tık menüsü etkinleştirilirken hata oluştu: $_" -ForegroundColor Red
    }
}

function Hide-News {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
        Set-RegistryDWORD -Path $regPath -Name "EnableFeeds" -Value 0 | Out-Null
        Write-Host "'Haberler ve İlgi Alanları' görev çubuğundan gizlendi." -ForegroundColor Green
    }
    catch {
        Write-Host "'Haberler ve İlgi Alanları' devre dışı bırakılırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Disable-SleepTimeout {
    try {
        Write-Host "Bilgisayarın uyku süreleri ayarlanıyor..." -ForegroundColor Yellow

        powercfg /change standby-timeout-ac 0 | Out-Null
        powercfg /change standby-timeout-dc 30 | Out-Null

        Write-Host "Uyku modu zaman aşımı güncellendi:" -ForegroundColor Green
        Write-Host "- Prize takılıyken: Hiçbir zaman"
        Write-Host "- Pildeyken: 30 dakika"
    }
    catch {
        Write-Host "Uyku modu zaman aşımı ayarlanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Set-LidCloseDoNothing {
    try {
        Write-Host "Kapak kapatma davranışı ayarlanıyor..." -ForegroundColor Yellow

        powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LidAction 0 | Out-Null
        powercfg /setactive SCHEME_CURRENT | Out-Null

        Write-Host "Kapak kapatıldığında (prizdeyken) hiçbir şey yapılmayacak şekilde ayarlandı." -ForegroundColor Green
    }
    catch {
        Write-Host "Kapak kapatma ayarı uygulanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Hide-RecentlyAddedApps {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-RegistryDWORD -Path $path -Name "Start_NotifyNewApps" -Value 0 | Out-Null
        Write-Host "Başlat menüsünde 'En son eklenen uygulamaları göster' kapatıldı." -ForegroundColor Green
    }
    catch {
        Write-Host "Son eklenen uygulamalar ayarı uygulanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Disable-StartRecommendedFiles {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-RegistryDWORD -Path $path -Name "Start_TrackDocs" -Value 0 | Out-Null
        Write-Host "Başlat menüsünde önerilen dosyalar ve son kullanılan öğeler kapatıldı." -ForegroundColor Green
    }
    catch {
        Write-Host "Önerilen dosyalar ayarı uygulanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Disable-StartTipsSuggestions {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-RegistryDWORD -Path $path -Name "Start_IrisRecommendations" -Value 0 | Out-Null
        Write-Host "Başlat menüsündeki ipuçları ve öneriler kapatıldı." -ForegroundColor Green
    }
    catch {
        Write-Host "Başlat ipuçları ayarı uygulanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Hide-MostUsedApps {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-RegistryDWORD -Path $path -Name "Start_TrackProgs" -Value 0 | Out-Null
        Write-Host "Başlat menüsünde 'En çok kullanılan uygulamaları göster' kapatıldı." -ForegroundColor Green
    }
    catch {
        Write-Host "En çok kullanılan uygulamalar ayarı uygulanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Disable-StartAccountNotifications {
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-RegistryDWORD -Path $path -Name "Start_AccountNotifications" -Value 0 | Out-Null
        Write-Host "Başlat menüsündeki hesap bildirimleri kapatıldı." -ForegroundColor Green
    }
    catch {
        Write-Host "Hesap bildirimleri ayarı uygulanırken hata oluştu: $_" -ForegroundColor Red
    }
}

function Disable-StartMenuSuggestions {
    try {
        Write-Host "`nBaşlat menüsü öneri ayarları uygulanıyor..." -ForegroundColor Cyan

        # Hide-RecentlyAddedApps
        Disable-StartRecommendedFiles
        Disable-StartTipsSuggestions
        Hide-MostUsedApps
        Disable-StartAccountNotifications

        Write-Host "Başlat menüsündeki öneri ve görünürlük ayarları kapatıldı." -ForegroundColor Green
    }
    catch {
        Write-Host "Başlat menüsü ayarları uygulanırken hata oluştu: $_" -ForegroundColor Red
    }
}