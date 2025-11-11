function Install-AptPackages {
    param(
        [ValidateSet("common", "advanced")]
        [string]$Type = "common"
    )

    Write-Host "APT ile $Type yazılımlar kuruluyor..."

    # JSON'dan APT paketlerini al
    $json = Get-SettingsJSON
    $aptPackages = $json.packages.linux.$Type.apt

    Write-Host "Kurulacak paketler: $aptPackages"

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

