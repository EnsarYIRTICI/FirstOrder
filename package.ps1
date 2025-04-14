. "$PSScriptRoot\service\functions.ps1"

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
            Write-Host "Seçilen yazılımlar Chocolatey ile kuruluyor..."
            choco install git wget nvm nodejs temurin21 micro vscode visualstudio2022community androidstudio docker-desktop openssl openssh virtualbox winscp qbittorrent steam discord opera tor-browser winrar cpu-z crystaldiskmark lghub googlechrome googledrive itunes icloud -y
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
            winget install --id "Python.Python.3.13" --accept-package-agreements --accept-source-agreements
            winget install --id "WhatsApp.WhatsApp" --accept-package-agreements --accept-source-agreements

            if ($isWin11)
            {
                winget install --id "Intel.Unison" --accept-package-agreements --accept-source-agreements
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
            sudo apt update
            sudo apt install -y micro net-tools nodejs npm docker.io
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
            brew update
            brew install git nvm nodejs openjdk@21 visual-studio-code python3 docker virtualbox qbittorrent discord
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
