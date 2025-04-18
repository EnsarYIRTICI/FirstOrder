. "$PSScriptRoot\Windows.Package.ps1"
. "$PSScriptRoot\MacOS.Package.ps1"
. "$PSScriptRoot\Linux.Package.ps1"

function Install-Packages {
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
}





