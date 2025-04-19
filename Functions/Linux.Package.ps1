function Install-AptPackages {
    Write-Host "APT ile Yaygın yazılımlar kuruluyor..."
    
    # JSON'dan APT paketlerini al
    $json = Get-SettingsJSON
    $aptPackages = $json.packages.linux.apt

    # Paketleri yükle
    foreach ($pkg in $aptPackages) {
        Write-Host "Kuruluyor: $pkg"
        apt install -y $pkg
    }
}

function Check-AptInstalled {
    $global:aptInstalled = Get-Command apt -ErrorAction SilentlyContinue
    return $aptInstalled -ne $null
}

