$Applications = @{
    "FirstOrder" = "C:\Users\ensar\repo\powershell\FirstOrder"
}

function xsh {
    param(
        [string]$Name = "FirstOrder"
    )

    if ($IsWindows) {
        Ensure-TerminalReady

        if ($Applications.ContainsKey($Name)) {
            $appPath = $Applications[$Name]
            $scriptPath = Join-Path $appPath "Main.ps1"

            if (-not (Test-Path $scriptPath)) {
                Write-Error "Main.ps1 bulunamadı: $scriptPath"
                return
            }

            Start-Process wt.exe -Verb RunAs -ArgumentList "pwsh `"$scriptPath`""

        } else {
            Write-Host "Uygulama bulunamadı: $Name" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Bu fonksiyon sadece Windows üzerinde çalışır." -ForegroundColor Red
    }
}

function xvs {
    param(
        [string]$Name = "FirstOrder"
    )

    Ensure-VscodeReady

    if ($Applications.ContainsKey($Name)) {
        code $Applications[$Name]
    }
    else {
        Write-Host "Uygulama bulunamadı: $Name" -ForegroundColor Red
    }
}

function xt {
    param(
        [string]$Name = "FirstOrder"
    )

    if ($Applications.ContainsKey($Name)) {
        cd $Applications[$Name]
    }
    else {
        Write-Host "Uygulama bulunamadı: $Name" -ForegroundColor Red
    }
}

function Ensure-TerminalReady {
    $pwshPath = Get-Command pwsh -ErrorAction SilentlyContinue
    $wtPath = Get-Command wt -ErrorAction SilentlyContinue

    if (-not $pwshPath) {
        Write-Error "pwsh (PowerShell 7) yüklü değil veya sistem PATH'inde değil."
        return
    }

    if (-not $wtPath) {
        Write-Error "wt (Windows Terminal) yüklü değil veya sistem PATH'inde değil."
        return
    }
}

function Ensure-VscodeReady {
    $vscodePath = Get-Command code -ErrorAction SilentlyContinue

    if (-not $vscodePath) {
        Write-Error "VSCode yüklü değil veya sistem PATH'inde değil."
        return
    }
}
