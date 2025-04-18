function Install-BrewPackages {
    Write-Host "Seçilen yazılımlar Homebrew ile kuruluyor..."
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

    foreach ($pkg in $brewPackages) {
        Write-Host "Kuruluyor: $pkg"
        brew install $pkg
    }
}

function Check-BrewInstalled {
    $global:brewInstalled = Get-Command brew -ErrorAction SilentlyContinue
    return $brewInstalled -ne $null
}