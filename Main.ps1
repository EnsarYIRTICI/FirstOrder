. "$PSScriptRoot\Functions\Package.ps1"
. "$PSScriptRoot\Functions\Guard.ps1"
. "$PSScriptRoot\Functions\IO.ps1"
. "$PSScriptRoot\Functions\Windows.ps1"
. "$PSScriptRoot\Functions\System.ps1"
. "$PSScriptRoot\Functions\Personalize.ps1"

$scriptDir = $PSScriptRoot

Assert-AdminRights

if (-not ($IsWindows -or $IsLinux -or $IsMacOS)) {
    $IsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
    $IsLinux = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)
    $IsMacOS = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)
}

# == ANA SEÇİM MENÜSÜ ==
Write-Host "`nNe yapmak istiyorsunuz?" -ForegroundColor Cyan
Write-Host "1. Sistem Ayarlarını Yapılandır"
Write-Host "2. Paket Yönetimi ile Yazılım Kurulumu"
$mainChoice = Read-Host "Seçiminiz (1/2)"

if ($mainChoice -eq "1") {
    # == SİSTEM AYARLARI ==
    if ($IsWindows) {
        # WINDOWS İÇİN
        Write-Host "`nWindows Sistem Ayarları" -ForegroundColor Green
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

        if (Ask-YesNo "Windows Update'i devre dışı bırakmak istiyor musun?") { Disable-WindowsUpdate }
        if (Ask-YesNo "Geliştirici Modu etkinleştirilsin mi?") { Enable-DeveloperMode }
        if (Ask-YesNo "WSL etkinleştirilsin ve kurulsun mu?") { Enable-WSL }
        if (Ask-YesNo "Hyper-V etkinleştirilsin mi?") { Enable-HyperV }
        if (Ask-YesNo "'misafir' adında bir misafir kullanıcı oluşturmak istiyor musun?") { Create-GuestUser }
        if (Ask-YesNo "Bilgisayarın uykuya geçme süresi ayarlansın mı? (prizde: Hiçbir zaman, pilde: 30 dakika)") { Disable-SleepTimeout }
        if (Ask-YesNo "Kapak kapatıldığında (prizdeyken) 'hiçbir şey yapma' olarak ayarlansın mı?") { Set-LidCloseDoNothing }
        if (Ask-YesNo "PowerShell başlangıcında özel ayarları (profile) yüklemek istiyor musun?") { Set-Profile }
    }
    elseif ($IsLinux) {
        # LINUX İÇİN
        Write-Host "`nLinux Sistem Ayarları" -ForegroundColor Green

    }
    elseif ($IsMacOS) {
        # MACOS İÇİN
        Write-Host "`nMacOS Sistem Ayarları" -ForegroundColor Green

    }
}

elseif ($mainChoice -eq "2") {
    # == PAKET YÖNETİMİ ==
    if ($IsWindows) {
        # WINDOWS İÇİN PAKET YÖNETİMİ
        Write-Host "`nWindows Paket Yönetimi" -ForegroundColor Green

        # Chocolatey
        $chocoInstalled = Check-ChocoInstalled
        if (-not $chocoInstalled) {
            if (Ask-YesNo "Chocolatey bulunamadı. Kurulsun mu?") {
                Install-Chocolatey
                $chocoInstalled = Check-ChocoInstalled
            }
        }

        if ($chocoInstalled -and (Ask-YesNo "Chocolatey ile yaygın yazılımlar kurulsun mu?")) {
            Install-ChocoPackages
        }

        # Winget
        $wingetInstalled = Check-WingetInstalled
        if (-not $wingetInstalled) {
            if (Ask-YesNo "Winget bulunamadı. Kurulsun mu?") {
                Install-Winget
                $wingetInstalled = Check-WingetInstalled
            }
        }

        if ($wingetInstalled -and (Ask-YesNo "Winget ile yaygın yazılımlar kurulsun mu?")) {
            Install-WingetPackages
        }
    }
    elseif ($IsLinux) {
        # LINUX İÇİN PAKET YÖNETİMİ
        Write-Host "`nLinux Paket Yönetimi" -ForegroundColor Green
        if (Check-AptInstalled) {
            if (Ask-YesNo "APT ile yaygın yazılımlar kurulsun mu?") {
                Install-AptPackages
            }
        } else {
            Write-Host "APT paket yöneticisi bulunamadı. Çıkılıyor..."
        }
    }
    elseif ($IsMacOS) {
        # MACOS İÇİN PAKET YÖNETİMİ
        Write-Host "`nMacOS Paket Yönetimi" -ForegroundColor Green
        if (Check-BrewInstalled) {
            if (Ask-YesNo("Homebrew ile yaygın yazılımlar kurulsun mu?")) {
                Install-BrewPackages
            }
        } else {
            Write-Host "Homebrew paket yöneticisi bulunamadı. Çıkılıyor..."
        }
    }
} else {
    Write-Host "Geçersiz seçim yapıldı. Çıkılıyor..." -ForegroundColor Red
}