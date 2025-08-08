. "$PSScriptRoot\IO.ps1"
. "$PSScriptRoot\Windows.Package.ps1"

function Add-VscodeOpenWith {
    $codePaths = @(
        "C:\Program Files\Microsoft VS Code\Code.exe",
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
    )

    $codePath = $codePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $codePath) {
        Write-Host "VS Code bulunamadı, kayıt eklenemedi." -ForegroundColor Red
        return
    }

    try {
        New-Item -Path "Registry::HKCR\Directory\shell\vscode" -Force | Out-Null
        Set-ItemProperty -Path "Registry::HKCR\Directory\shell\vscode" -Name "(Default)" -Value "VS Code ile Aç"
        Set-ItemProperty -Path "Registry::HKCR\Directory\shell\vscode" -Name "Icon" -Value "`"$codePath`""
        New-Item -Path "Registry::HKCR\Directory\shell\vscode\command" -Force | Out-Null
        Set-ItemProperty -Path "Registry::HKCR\Directory\shell\vscode\command" -Name "(Default)" -Value "`"$codePath`" `"%1`""

        Write-Host "'VS Code ile Aç' sağ tık menüsüne eklendi." -ForegroundColor Green
    }
    catch {
        Write-Host "Hata: Kayıt defteri değiştirilemedi. PowerShell'i yönetici olarak çalıştırmayı deneyin." -ForegroundColor Red
    }
}

function Check-VscodeInstalled {
    $vscodePaths = @(
        "C:\Program Files\Microsoft VS Code\Code.exe",
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
    )

    foreach ($path in $vscodePaths) {
        if (Test-Path $path) {
            return $true
        }
    }

    return $false
}

function Install-VscodeWithChoco {
    if (Check-ChocoInstalled) {
        Write-Host "Visual Studio Code Chocolatey ile yükleniyor..." -ForegroundColor Yellow
        choco install vscode --ignore-checksums -y
    }
    else {
        Write-Host "Chocolatey bulunamadı, lütfen manuel kurulum yapınız."
        return
    }
}


