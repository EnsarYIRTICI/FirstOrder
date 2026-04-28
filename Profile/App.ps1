# Profile\App.ps1

function Get-Applications {
    $settingsPath = Join-Path $HOME 'repo\powershell\FirstOrder\settings.json'

    if (-not (Test-Path $settingsPath)) {
        Write-Warning "settings.json bulunamadı: $settingsPath"
        return @{}
    }

    $json = Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable

    if (-not $json.ContainsKey('apps')) {
        Write-Warning "settings.json içinde 'apps' bloğu bulunamadı."
        return @{}
    }

    $result = @{}
    foreach ($key in $json['apps'].Keys) {
        $result[$key] = Join-Path $HOME $json['apps'][$key]
    }

    return $result
}

$Applications = Get-Applications


# Ortak: app adı seçtir ya da -List ile listele
function Resolve-AppName {
    param(
        [string]$N,
        [switch]$List
    )

    if ($List) {
        Write-Host ""
        Write-Host "Kayıtlı uygulamalar:" -ForegroundColor Cyan
        foreach ($key in $Applications.Keys | Sort-Object) {
            Write-Host "  • $key  →  $($Applications[$key])" -ForegroundColor Gray
        }
        Write-Host ""
        return $null
    }

    if (-not $N) {
        $keys = $Applications.Keys | Sort-Object

        Write-Host ""
        Write-Host "Uygulama seçin:" -ForegroundColor Cyan

        $i = 1
        $indexMap = @{}
        foreach ($key in $keys) {
            Write-Host "  [$i] $key" -ForegroundColor Gray
            $indexMap[$i] = $key
            $i++
        }

        Write-Host ""
        $input = Read-Host "Numara"

        $num = $input -as [int]
        if ($null -eq $num -or -not $indexMap.ContainsKey($num)) {
            Write-Host "Geçersiz seçim." -ForegroundColor Red
            return $null
        }

        return $indexMap[$num]
    }

    if (-not $Applications.ContainsKey($N)) {
        Write-Host "Uygulama bulunamadı: $N" -ForegroundColor Red
        Write-Host "Kayıtlı uygulamalar için -List parametresini kullanın." -ForegroundColor DarkGray
        return $null
    }

    return $N
}


function xsh {
    param(
        [string]$N,
        [switch]$List
    )

    $appName = Resolve-AppName -N $N -List:$List
    if (-not $appName) { return }

    if ($IsWindows) {
        Ensure-TerminalReady

        $appPath    = $Applications[$appName]
        $scriptPath = Join-Path $appPath "Main.ps1"

        if (-not (Test-Path $scriptPath)) {
            Write-Error "Main.ps1 bulunamadı: $scriptPath"
            return
        }

        Start-Process wt.exe -Verb RunAs -ArgumentList "pwsh `"$scriptPath`""
    }
    else {
        Write-Host "Bu fonksiyon sadece Windows üzerinde çalışır." -ForegroundColor Red
    }
}

function xvs {
    param(
        [string]$N,
        [switch]$List
    )

    $appName = Resolve-AppName -N $N -List:$List
    if (-not $appName) { return }

    Ensure-VscodeReady
    code $Applications[$appName]
}

function xt {
    param(
        [string]$N,
        [switch]$List
    )

    $appName = Resolve-AppName -N $N -List:$List
    if (-not $appName) { return }

    Set-Location $Applications[$appName]
}

function xtn {
    param(
        [string]$N,
        [switch]$List
    )

    if ($IsWindows) {
        Ensure-TerminalReady

        $targetDir = "."

        if ($N -or $List) {
            $appName = Resolve-AppName -N $N -List:$List
            if (-not $appName) { return }
            $targetDir = $Applications[$appName]
        }

        wt -w 0 nt -d $targetDir
    }
    else {
        Write-Host "Bu fonksiyon sadece Windows üzerinde çalışır." -ForegroundColor Red
    }
}


function Ensure-TerminalReady {
    if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
        Write-Error "pwsh (PowerShell 7) yüklü değil veya PATH'de değil."
        return
    }
    if (-not (Get-Command wt -ErrorAction SilentlyContinue)) {
        Write-Error "wt (Windows Terminal) yüklü değil veya PATH'de değil."
        return
    }
}

function Ensure-VscodeReady {
    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Error "VSCode yüklü değil veya PATH'de değil."
        return
    }
}