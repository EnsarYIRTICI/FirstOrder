function Install-AptPackages {
    Write-Host "Seçilen yazılımlar APT ile kuruluyor..."
    $aptPackages = @(
        "micro",
        "net-tools",
        "nodejs",
        "npm",
        "docker.io"
    )

    apt update

    foreach ($pkg in $aptPackages) {
        apt install -y $pkg
    }
}

function Check-AptInstalled {
    $global:aptInstalled = Get-Command apt -ErrorAction SilentlyContinue
    return $aptInstalled -ne $null
}

