. "$PSScriptRoot\Functions\IO.ps1"
. "$PSScriptRoot\Functions\Guard.ps1"
. "$PSScriptRoot\Functions\System.ps1"
. "$PSScriptRoot\Functions\Personalize.ps1"
. "$PSScriptRoot\Functions\Package.ps1"

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
Write-Host "2. Kişiselleştirme Ayarlarını Yapılandır"
Write-Host "3. Paket Yönetimi ile Yazılım Kurulumu"
$mainChoice = Read-Host "Seçiminiz (1-3)"

if ($mainChoice -eq "1") {
    # == SİSTEM AYARLARI ==
    System-Settings
}

elseif ($mainChoice -eq "2") {
    # == KİŞİSELLEŞTİRME AYARLARI ==
    Personalize-Settings

} 
elseif ($mainChoice -eq "3") {
    # == PAKET YÖNETİMİ ==
    Install-Packages
} else {
    Write-Host "Geçersiz seçim yapıldı. Çıkılıyor..." -ForegroundColor Red
}