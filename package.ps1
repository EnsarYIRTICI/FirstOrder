. "$PSScriptRoot\Service\SystemSetup.ps1"

# Sürüm bilgileri

$PSVersion = $PSVersionTable.PSVersion
$osVersion = [System.Environment]::OSVersion.Version

$setup = [SystemSetup]::new()

$setup.AssertAdminRights()

if ($IsWindows)
{
    $windowsMajor = $osVersion.Major
    $windowsBuild = $osVersion.Build

    $isWin10 = $windowsMajor -eq 10 -and $windowsBuild -lt 22000
    $isWin11 = $windowsMajor -eq 10 -and $windowsBuild -ge 22000

    $chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
    $wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue

    if (-not $chocoInstalled) 
    {
        $userInput = Read-Host "Chocolatey bulunamadı. Kurulsun mu? (e/h)"
        if ($userInput.ToLower() -eq "e") 
        {
            $setup.InstallChocolatey()
            $chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
        }
    } 

    # Yaygın yazılım kurulumları (Chocolatey)
    if ($chocoInstalled)
    {
        if ($isWin11)
        {
            $userInput = Read-Host "Chocolatey ile PowerShell Core kurulsun mu? (e/h)"
            if ($userInput.ToLower() -eq "e")
            {
                Write-Host "Seçilen yazılımlar Chocolatey ile kuruluyor..."
                choco install pwsh -y
            }
        }

        if ($isWin10)
        {
            $userInput = Read-Host "Chocolatey ile 'PowerShell Core' ve 'Windows Terminal' kurulsun mu? (e/h)" 
            if ($userInput.ToLower() -eq "e") 
            {
                Write-Host "Seçilen yazılımlar Chocolatey ile kuruluyor..."
                choco install pwsh microsoft-windows-terminal -y
            }
        }

        $userInput = Read-Host "Chocolatey ile Yaygın yazılımlar kurulsun mu? (e/h)"
        if ($userInput.ToLower() -eq "e")
        {
            # Yaygın yazılımlar dizisi
            $commonPackages = @(
                "git", "wget", "nvm", "nodejs", "temurin21", "micro", "thunderbird",
                "vscode", "visualstudio2022community", "androidstudio", "docker-desktop",
                "openssl", "openssh", "virtualbox", "winscp", "qbittorrent", "steam",
                "discord", "opera", "tor-browser", "winrar", "cpu-z", "crystaldiskmark",
                "lghub", "googlechrome", "googledrive", "itunes", "icloud"
            )
            
            Write-Host "Seçilen yazılımlar Chocolatey ile kuruluyor..."

            # Kurulum döngüsü
            foreach ($pkg in $commonPackages) 
            {
                choco install $pkg -y
            }
        }
    }

    # Winget kurulumu
    if (-not $wingetInstalled) 
    {
        $userInput = Read-Host "Winget bulunamadı. Kurulsun mu? (e/h)"
        if ($userInput.ToLower() -eq "e")
        {
            $setup.InstallWinget()
            $wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
        }
    }

    # Yaygın yazılım kurulumları (Winget)
    if ($wingetInstalled)
    {
        $userInput = Read-Host "Winget ile diğer Yaygın yazılımlar kurulsun mu? (e/h)"
        if ($userInput.ToLower() -eq "e")
        {
            Write-Host "Seçilen yazılımlar WinGet ile kuruluyor..."

            # Yaygın yazılımlar dizisi
            $wingetPackages = @(
                "Python.Python.3.13",
                "WhatsApp.WhatsApp"
            )

            # Windows 11'e özel yazılımları ekle
            if ($isWin11) 
            {
                $wingetPackages += "Intel.Unison"
            }

            # Kurulum döngüsü
            foreach ($pkg in $wingetPackages) 
            {
                Write-Host "Kuruluyor: $pkg"
                winget install --id $pkg --accept-package-agreements --accept-source-agreements
            }
        }
    }

}
elseif ($IsLinux)
{
    $aptInstalled = Get-Command apt -ErrorAction SilentlyContinue

    if ($aptInstalled) 
    {
        $userInput = Read-Host "APT ile yaygın yazılımlar kurulsun mu? (e/h)"
        if ($userInput.ToLower() -eq "e") 
        {
            Write-Host "Seçilen yazılımlar APT ile kuruluyor..."

            # Yaygın yazılımlar dizisi
            $aptPackages = @(
                "micro",
                "net-tools",
                "nodejs",
                "npm",
                "docker.io"
            )

            # Kurulum
            $packagesString = $aptPackages -join " "
            sudo apt update && sudo apt install -y $packagesString
        }
    }
    else 
    {
        Write-Host "Hiçbir paket yöneticisi bulunamadı. Çıkılıyor..."
    }

}
elseif ($IsMacOS) 
{
    $brewInstalled = Get-Command brew -ErrorAction SilentlyContinue

    if ($brewInstalled) 
    {
        $userInput = Read-Host "Homebrew ile yaygın yazılımlar kurulsun mu? (e/h)"
        if ($userInput.ToLower() -eq "e") 
        {
            Write-Host "Seçilen yazılımlar Homebrew ile kuruluyor..."

            # Yaygın yazılımlar dizisi
            $brewPackages = @(
                "git",
                "nvm",
                "nodejs",
                "openjdk@21",
                "visual-studio-code",
                "python3",
                "docker",
                "virtualbox",
                "qbittorrent",
                "discord"
            )

            brew update

            # Kurulum döngüsü
            foreach ($pkg in $brewPackages) {
                Write-Host "Kuruluyor: $pkg"
                brew install $pkg
            }
        }
    }
    else 
    {
        $userInput = Read-Host "Hiçbir paket yöneticisi bulunamadı. Çıkılsın mı? (e/h)"
        if ($userInput.ToLower() -eq "e") 
        {
            Write-Host "Hiçbir paket yöneticisi bulunamadı. Çıkılıyor..."
        }
    }
}
