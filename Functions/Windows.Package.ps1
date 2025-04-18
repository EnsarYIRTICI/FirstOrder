function Install-ChocoPackages {
    Write-Host "Chocolatey ile Yaygın yazılımlar kuruluyor..."
    $commonPackages = @(
        "pwsh", "microsoft-windows-terminal", "thunderbird", "virtualbox", "winscp", "winrar",
        "qbittorrent", "steam", "discord", "opera", "cpu-z", "crystaldiskmark",
        "lghub", "googlechrome", "googledrive", "itunes", "icloud", "anydesk",
        "vscode", "visualstudio2022community", "androidstudio", "docker-desktop",
        "git", "wget", "nvm", "nodejs", "temurin21", "micro", "openssl", "openssh",
        "flutter"
    )
    
    foreach ($pkg in $commonPackages) {
        choco install $pkg -y
    }
}

function Install-WingetPackages {
    Write-Host "Winget ile Yaygın yazılımlar kuruluyor..."
    $wingetPackages = @(
        "Python.Python.3.13",
        "WhatsApp.WhatsApp",
        "Intel.Unison"
    )

    foreach ($pkg in $wingetPackages) {
        Write-Host "Kuruluyor: $pkg"
        winget install --id $pkg --accept-package-agreements --accept-source-agreements
    }
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

function Check-ChocoInstalled {
    $global:chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
    return $global:chocoInstalled -ne $null
}

function Check-WingetInstalled {
    $global:wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
    return $global:wingetInstalled -ne $null
}