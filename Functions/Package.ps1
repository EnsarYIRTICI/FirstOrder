function Check-ChocoInstalled {
    $global:chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
    return $global:chocoInstalled -ne $null
}

function Check-WingetInstalled {
    $global:wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
    return $global:wingetInstalled -ne $null
}

function Check-AptInstalled {
    $global:aptInstalled = Get-Command apt -ErrorAction SilentlyContinue
    return $aptInstalled -ne $null
}

function Check-BrewInstalled {
    $global:brewInstalled = Get-Command brew -ErrorAction SilentlyContinue
    return $brewInstalled -ne $null
}


function Install-Chocolatey {
    if (-not $IsWindows) {
        Write-Log "Chocolatey sadece Windows sistemlerde kullanılabilir."
        return
    }

    Write-Log "Chocolatey kuruluyor..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    if ($?) {
        Write-Log "Chocolatey başarıyla kuruldu."
    } else {
        Write-Log "Chocolatey kurulumu başarısız oldu."
    }
}

function Install-Winget {
    if (-not $IsWindows) {
        Write-Log "Winget sadece Windows sistemlerde kullanılabilir."
        return
    }

    try {
        $ProgressPreference = 'SilentlyContinue'
        Write-Log "WinGet PowerShell modülü PSGallery üzerinden kuruluyor..."
        
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null

        Write-Log "WinGet modülü indirildi. Bootstrap işlemi başlatılıyor..."
        Repair-WinGetPackageManager

        Write-Log "WinGet bootstrap tamamlandı. Terminali yeniden başlatmanız gerekebilir."
    } catch {
        Write-Log "Winget kurulumu sırasında bir hata oluştu: $_"
    }
}


function Install-ChocoPackages {
    Write-Host "Chocolatey ile Yaygın yazılımlar kuruluyor..."
    $commonPackages = @(
        "git", "wget", "nvm", "nodejs", "temurin21", "micro", "thunderbird",
        "vscode", "visualstudio2022community", "androidstudio", "docker-desktop",
        "openssl", "openssh", "virtualbox", "winscp", "qbittorrent", "steam",
        "discord", "opera", "tor-browser", "winrar", "cpu-z", "crystaldiskmark",
        "lghub", "googlechrome", "googledrive", "itunes", "icloud"
    )
    
    foreach ($pkg in $commonPackages) {
        choco install $pkg -y
    }
}

function Install-WingetPackages {
    Write-Host "Winget ile Yaygın yazılımlar kuruluyor..."
    $wingetPackages = @(
        "Python.Python.3.13",
        "WhatsApp.WhatsApp"
    )

    # Windows 11'e özel yazılımları ekle
    if ($isWin11) {
        $wingetPackages += "Intel.Unison"
    }

    foreach ($pkg in $wingetPackages) {
        Write-Host "Kuruluyor: $pkg"
        winget install --id $pkg --accept-package-agreements --accept-source-agreements
    }
}

function Install-AptPackages {
    Write-Host "Seçilen yazılımlar APT ile kuruluyor..."
    $aptPackages = @(
        "micro",
        "net-tools",
        "nodejs",
        "npm",
        "docker.io"
    )

    $packagesString = $aptPackages -join " "
    sudo apt update && sudo apt install -y $packagesString
}

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