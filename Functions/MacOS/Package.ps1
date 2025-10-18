function Install-BrewPackages {
    param(
        [ValidateSet("common", "advanced")]
        [string]$Type = "common"
    )

    Write-Host "Homebrew ile $Type yazılımlar kuruluyor..."

    # JSON'dan Homebrew paketlerini al
    $json = Get-SettingsJSON
    $brewPackages = $json.packages.macos.$Type.brew

    Write-Host "Kurulacak paketler: $brewPackages"

    # Paketleri yükle
    foreach ($pkg in $brewPackages) {
        Write-Host "Kuruluyor: $pkg"
        brew install $pkg
    }
}

function Check-BrewInstalled {
    $global:brewInstalled = Get-Command brew -ErrorAction SilentlyContinue
    return $brewInstalled -ne $null
}