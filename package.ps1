. "$PSScriptRoot\service\functions.ps1"

Assert-AdminRights

# Sürüm bilgileri
$PSVersion = $PSVersionTable.PSVersion
$osVersion = [System.Environment]::OSVersion.Version
$windowsMajor = $osVersion.Major
$windowsBuild = $osVersion.Build

$isWin10 = $windowsMajor -eq 10 -and $windowsBuild -lt 22000
$isWin11 = $windowsMajor -eq 10 -and $windowsBuild -ge 22000

# Paket kontrolü
$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
$wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue

# Chocolatey kurulumu
if ($chocoInstalled) {
    if (Confirm-Action "Chocolatey yüklü. Chocolatey yeniden kurulsun mu?") 
    {
        Install-Chocolatey
    }

} else {
    if (Confirm-Action "Chocolatey kurulsun mu?") 
    {
        Install-Chocolatey
        $chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
    }
}


# Yaygın yazılım kurulumları
if($chocoInstalled)
{
    if($isWin11)
    {
        if (Confirm-Action "Chocolatey yüklü. PowerShell Core kurulsun mu?")
         {
            Write-Log "Seçilen yazılımlar Chocolatey ile kuruluyor..."
            choco install pwsh -y
        }
    }

    if($isWin10)
    {
        if (Confirm-Action "Chocolatey yüklü. 'PowerShell Core' ve 'Windows Terminal' kurulsun mu?") 
        {
            Write-Log "Seçilen yazılımlar Chocolatey ile kuruluyor..."
            choco install pwsh microsoft-windows-terminal -y
        }
    }

    if(Confirm-Action "Chocolatey yüklü. Yaygın yazılımlar kurulsun mu?")
    {
        Write-Log "Seçilen yazılımlar Chocolatey ile kuruluyor..."
        choco install git nvm nodejs temurin21 vscode visualstudio2022community androidstudio docker-desktop openssl openssh virtualbox winscp qbittorrent steam discord opera tor-browser winrar cpu-z crystaldiskmark lghub googlechrome googledrive itunes icloud -y
    }
}


# Winget kurulumu
if ($wingetInstalled) 
{
    if (Confirm-Action "Winget yüklü. Yeniden kurulsun mu?")
    {
        Install-Winget
    }
} else {
    if (Confirm-Action "Winget bulunamadı. Kurulsun mu?")
     {
        Install-Winget
        $wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
    }
}

# Yaygın yazılım kurulumları
if($wingetInstalled)
{
    if($isWin11)
    {
        if (Confirm-Action "Winget yüklü. Yaygın yazılımlar kurulsun mu?") 
        {
            Write-Log "Seçilen yazılımlar WinGet ile kuruluyor..."
            winget install "Intel® Unison™" "Python 3.13" "WhatsApp" --accept-package-agreements --accept-source-agreements
        }
    }
    
    if($isWin10){
        if (Confirm-Action "Winget yüklü. Yaygın yazılımlar kurulsun mu?") 
        {
            Write-Log "Seçilen yazılımlar WinGet ile kuruluyor..."
            winget install "Python 3.13" "WhatsApp" --accept-package-agreements --accept-source-agreements
        }
    }
}



