. "$scriptDir\Components\Show-Menu.ps1"
. "$scriptDir\Functions\Core\Android.ps1"

function Invoke-IfExists {
    param([Parameter(Mandatory)][string]$Fn)
    if (Get-Command $Fn -ErrorAction SilentlyContinue) {
        & (Get-Command $Fn)
    } else {
        Write-Host "$Fn fonksiyonu bulunamadı. İlgili modülü import ettiğinizden emin olun." -ForegroundColor Red
    }
}

function Android-Menu{

    # OS bekçisi
    if (-not $IsWindows) {
        Write-Host "Android otomasyonları şu an yalnızca Windows için tanımlı." -ForegroundColor Yellow
        return
    }

    # Alt menü öğeleri (Show-MainMenu için)
    $androidMenuItems = @(
        @{ Label = "Android Studio kur (Chocolatey)"; Action = { Invoke-IfExists -Fn 'Install-AndroidStudio' } },
        @{ Label = "CLI Tools + SDK (sdkmanager) kur"; Action = { Invoke-IfExists -Fn 'Install-AndroidCLITools' } },
        @{ Label = "Temurin 21 ve 17 kur (17’yi varsayılan yap)"; Action = { Invoke-IfExists -Fn 'Install-Temurin' } },
        @{ Label = "Temel SDK paketleri (platform-tools, emulator, platform/build-tools)"; Action = { Invoke-IfExists -Fn 'Android-InstallBasePackages' } },
        @{ Label = "SDK lisanslarını kabul et"; Action = { Invoke-IfExists -Fn 'Android-AcceptLicenses' } },
        @{ Label = "ANDROID_SDK_ROOT / JAVA_HOME / PATH ayarla"; Action = { Invoke-IfExists -Fn 'Android-SetEnvPaths' } },
        @{ Label = "Hepsini yap (önerilen)"; Action = { Invoke-IfExists -Fn 'Android-DoAll' } }
    )

    # Alt menüyü göster
    if (Get-Command Show-Menu -ErrorAction SilentlyContinue) {
        Show-Menu -MenuItems $androidMenuItems -Title "Android Menüsü" -ClearOnEachLoop -PauseAfterAction
    } else {
        Write-Host "Show-MainMenu bulunamadı. Lütfen ortak menü bileşenini yükleyin." -ForegroundColor Red
    }
}
