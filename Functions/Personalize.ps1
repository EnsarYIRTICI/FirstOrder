. "$PSScriptRoot\Windows.System.ps1"
. "$PSScriptRoot\Windows.Personalize.ps1"
. "$PSScriptRoot\Git.ps1"

function Personalize-Settings {
    Detect-WindowsVersion

    Write-Host "`nGenel Kişiselleştirme Ayarları" -ForegroundColor Green

    if(Check-GitInstalled){
        if (Ask-YesNo "Git kullanıcı adı ve e-posta ayarlarını yapalım mı?") { Set-GitGlobalConfig }
    }

    if($IsWindows){
        Write-Host "`nWindows Kişiselleştirme Ayarları" -ForegroundColor Green
        if (Ask-YesNo "Karanlık moda geçirmek istiyor musun?") { Set-DarkMode }
        if (Ask-YesNo "Arama kutusunu simge olarak göstermek ister misiniz?") { Set-SearchBoxIcon }
        if (Ask-YesNo "'Görev Görünümü' görev çubuğundan gizlensin mi?") { Hide-TaskViewButton }
        if (Ask-YesNo "'Bu Bilgisayar' ve 'Denetim Masası' simgeleri masaüstüne eklensin mi?") { Add-DesktopIcons }

        if ($isWin11) {
            if (Ask-YesNo "Görev çubuğu simgelerini sola hizalamak istiyor musun?") { Align-TaskbarLeft }
            if (Ask-YesNo "'Pencere Öğeleri' (Widgetlar) özelliğini tamamen devre dışı bırakmak istiyor musun?") { Disable-Widgets }
            if (Ask-YesNo "Klasik sağ tık menüsünü geri getirmek istiyor musun?") { Enable-ClassicContextMenu }
        }

        if ($isWin10) {
            if (Ask-YesNo "'Haberler ve İlgi Alanları' görev çubuğundan gizlensin mi?") { Hide-News }
        }

        if (Ask-YesNo "Dosya uzantılarını görünür yapmak ister misin?") { Show-FileExtensions }
        if (Ask-YesNo "Gizli dosya ve klasörleri göstermek ister misin?") { Show-HiddenItems }

        if (Ask-YesNo "PowerShell başlangıcında özel ayarları (profile) yüklemek istiyor musun?") { Set-Profile }
        if (Ask-YesNo "Bilgisayarın uykuya geçme süresi ayarlansın mı? (prizde: Hiçbir zaman, pilde: 30 dakika)") { Disable-SleepTimeout }
        if (Ask-YesNo "Kapak kapatıldığında (prizdeyken) 'hiçbir şey yapma' olarak ayarlansın mı?") { Set-LidCloseDoNothing }
    }
    elseif($IsLinux){
        Write-Host "`nLinux Kişiselleştirme Ayarları" -ForegroundColor Green

    }
    elseif($IsMacOS){
        Write-Host "`nMacOS Kişiselleştirme Ayarları" -ForegroundColor Green

    }
}