function Install-BrewPackages {
    Write-Host "Homebrew ile Yaygın yazılımlar kuruluyor..."
    
    # JSON'dan Homebrew paketlerini al
    $json = Get-SettingsJSON
    $brewPackages = $json.packages.macos.brew

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