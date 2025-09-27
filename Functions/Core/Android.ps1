# Functions\Core\Android.ps1
# requires -Version 5.1

#region Yardımcılar

function Test-Choco {
    return [bool](Get-Command choco -ErrorAction SilentlyContinue)
}

function Ensure-Choco {
    if (-not (Test-Choco)) {
        Write-Host "Chocolatey bulunamadı. Kurulum talimatı: https://chocolatey.org/install" -ForegroundColor Red
        throw "Chocolatey gerekli."
    }
}

function Add-PathOnce {
    param(
        [Parameter(Mandatory)] [string] $PathToAdd,
        [ValidateSet('Machine','User')] [string] $Target = 'Machine'
    )
    if (-not (Test-Path $PathToAdd)) { return }
    $scope = [EnvironmentVariableTarget]::$Target
    $current = [Environment]::GetEnvironmentVariable('Path', $scope)
    if ([string]::IsNullOrWhiteSpace($current)) { $current = "" }
    if ($current -notmatch [Regex]::Escape($PathToAdd)) {
        $new = ($current.TrimEnd(';') + ';' + $PathToAdd).Trim(';')
        [Environment]::SetEnvironmentVariable('Path', $new, $scope)
        Write-Host "PATH eklendi: $PathToAdd ($Target)" -ForegroundColor DarkGray
    }
}

function Set-EnvVar {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Value,
        [ValidateSet('Machine','User')] [string] $Target = 'Machine'
    )
    [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::$Target)
    Write-Host "$Name = $Value ($Target)" -ForegroundColor DarkGray
}

function Get-LatestTemurinPath {
    param([int]$Major)
    $base = "C:\Program Files\Eclipse Adoptium"
    if (-not (Test-Path $base)) { return $null }
    $candidates = Get-ChildItem -Path $base -Directory -Filter "jdk-$Major*" -ErrorAction SilentlyContinue
    $latest = $candidates | Sort-Object Name -Descending | Select-Object -First 1
    return $latest?.FullName
}

function Ensure-AndroidSdkFolders {
    $sdkRoot = "$env:LOCALAPPDATA\Android\Sdk"
    New-Item -ItemType Directory -Force -Path $sdkRoot | Out-Null
    New-Item -ItemType Directory -Force -Path "$sdkRoot\cmdline-tools" | Out-Null
    return $sdkRoot
}

#endregion

#region Kurulum Fonksiyonları

function Install-AndroidStudio {
    if (-not $IsWindows) { Write-Host "Sadece Windows destekleniyor." -ForegroundColor Yellow; return }
    Ensure-Choco
    Write-Host "Android Studio kuruluyor (Chocolatey)..." -ForegroundColor Green
    choco install androidstudio -y --no-progress
}

function Install-Temurin {
    if (-not $IsWindows) { Write-Host "Sadece Windows destekleniyor." -ForegroundColor Yellow; return }
    Ensure-Choco
    Write-Host "Temurin 21 ve 17 kuruluyor (Chocolatey)..." -ForegroundColor Green
    choco install temurin21 temurin17 -y --no-progress

    # JAVA_HOME (17) ve PATH’i 17’ye set et
    $jdk17 = Get-LatestTemurinPath -Major 17
    if ($jdk17) {
        Set-EnvVar -Name "JAVA_HOME" -Value $jdk17 -Target Machine
        Add-PathOnce -PathToAdd "$jdk17\bin" -Target Machine
        Write-Host "JAVA_HOME 17 olarak ayarlandı ve PATH eklendi." -ForegroundColor Green
    } else {
        Write-Host "Temurin 17 yolu bulunamadı; elle kontrol ediniz." -ForegroundColor Yellow
    }
}

function Install-AndroidCLITools {
    if (-not $IsWindows) { Write-Host "Sadece Windows destekleniyor." -ForegroundColor Yellow; return }

    # Google cmdline-tools (varsayılan link sürüm değişebilir)
    $ZipUrl = "https://dl.google.com/android/repository/commandlinetools-win-10406996_latest.zip"

    $sdkRoot = Ensure-AndroidSdkFolders
    $zip = Join-Path $env:TEMP "cmdline-tools-win.zip"

    Write-Host "Android Command-line Tools indiriliyor..." -ForegroundColor Green
    Invoke-WebRequest -Uri $ZipUrl -OutFile $zip -UseBasicParsing

    $extractDir = Join-Path $env:TEMP "cmdline-tools-win-extract"
    if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $extractDir

    $target = Join-Path $sdkRoot "cmdline-tools\latest"
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    New-Item -ItemType Directory -Path $target | Out-Null

    # Zip içinde "cmdline-tools" klasörü bulunur
    Copy-Item -Path (Join-Path $extractDir "cmdline-tools\*") -Destination $target -Recurse

    # Ortam değişkenleri
    Set-EnvVar -Name "ANDROID_SDK_ROOT" -Value $sdkRoot -Target Machine
    Set-EnvVar -Name "ANDROID_HOME"     -Value $sdkRoot -Target Machine

    # PATH
    Add-PathOnce -PathToAdd "$sdkRoot\platform-tools"             -Target Machine
    Add-PathOnce -PathToAdd "$sdkRoot\cmdline-tools\latest\bin"   -Target Machine
    Add-PathOnce -PathToAdd "$sdkRoot\emulator"                   -Target Machine

    Write-Host "CLI tools kuruldu. ANDROID_SDK_ROOT/ANDROID_HOME ve PATH güncellendi." -ForegroundColor Green
}

function Android-AcceptLicenses {
    $sdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $sdkRoot) { $sdkRoot = "$env:LOCALAPPDATA\Android\Sdk" }
    $sdkMgr = Join-Path $sdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
    if (-not (Test-Path $sdkMgr)) {
        Write-Host "sdkmanager bulunamadı. Önce CLI tools kurun." -ForegroundColor Red
        return
    }
    Write-Host "Android SDK lisansları kabul ediliyor..." -ForegroundColor Green
    # Etkileşimli onay ekranı açar
    cmd /c "$sdkMgr --licenses"
}

function Android-InstallBasePackages {
    param(
        [string] $PlatformApi = "android-34",
        [string] $BuildTools  = "34.0.0"
    )
    $sdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $sdkRoot) { $sdkRoot = "$env:LOCALAPPDATA\Android\Sdk" }
    $sdkMgr = Join-Path $sdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
    if (-not (Test-Path $sdkMgr)) {
        Write-Host "sdkmanager bulunamadı. Önce CLI tools kurun." -ForegroundColor Red
        return
    }

    Write-Host "Temel Android SDK paketleri yükleniyor..." -ForegroundColor Green
    & $sdkMgr --install `
        "platform-tools" `
        "emulator" `
        "platforms;$PlatformApi" `
        "build-tools;$BuildTools"
}

function Android-SetEnvPaths {
    $sdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $sdkRoot) { $sdkRoot = "$env:LOCALAPPDATA\Android\Sdk" }

    Set-EnvVar -Name "ANDROID_SDK_ROOT" -Value $sdkRoot -Target Machine
    Set-EnvVar -Name "ANDROID_HOME"     -Value $sdkRoot -Target Machine

    Add-PathOnce -PathToAdd "$sdkRoot\platform-tools"             -Target Machine
    Add-PathOnce -PathToAdd "$sdkRoot\cmdline-tools\latest\bin"   -Target Machine
    Add-PathOnce -PathToAdd "$sdkRoot\emulator"                   -Target Machine

    # JAVA 17’i aktif tut
    $jdk17 = Get-LatestTemurinPath -Major 17
    if ($jdk17) {
        Set-EnvVar -Name "JAVA_HOME" -Value $jdk17 -Target Machine
        Add-PathOnce -PathToAdd "$jdk17\bin" -Target Machine
    }
    Write-Host "Ortam değişkenleri ve PATH senkronize edildi." -ForegroundColor Green
}

function Android-UpdateSDK {
    # Tüm kurulu paketleri günceller (mevcutlara update)
    $sdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $sdkRoot) { $sdkRoot = "$env:LOCALAPPDATA\Android\Sdk" }
    $sdkMgr = Join-Path $sdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
    if (-not (Test-Path $sdkMgr)) {
        Write-Host "sdkmanager bulunamadı. Önce CLI tools kurun." -ForegroundColor Red
        return
    }
    Write-Host "Android SDK paketleri güncelleniyor..." -ForegroundColor Green
    & $sdkMgr --update
}

function Android-DoAll {
    if (-not $IsWindows) {
        Write-Host "Android otomasyonları şu an yalnızca Windows için tanımlı." -ForegroundColor Yellow
        return
    }

    Install-AndroidStudio
    Install-Temurin
    Install-AndroidCLITools
    Android-InstallBasePackages
    Android-AcceptLicenses
    Android-SetEnvPaths

    Write-Host "`nTamamlandı. Ortam değişkenlerinin uygulanması için yeni bir PowerShell penceresi açman veya oturumu kapatıp açman önerilir." -ForegroundColor Cyan
}

#endregion
