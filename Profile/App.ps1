$Applications = @{
    "FirstOrder" = "C:\Users\ensar\repo\powershell\FirstOrder"
}


function FirstOrder {
    if($IsWindows){
        Ensure-TerminalReady

        $appPath = "C:\Users\ensar\repo\powershell\FirstOrder"
        $scriptPath = "C:\Users\ensar\repo\powershell\FirstOrder\Main.ps1"

        if (-not (Test-Path $scriptPath)) {
            Write-Error "Main.ps1 bulunamadı: $scriptPath"
            return
        }

        try {
            Start-Process wt.exe -Verb RunAs -ArgumentList "pwsh `"$scriptPath`""
        } catch {
            Write-Error "Windows Terminal başlatılamadı: $_"
        }
    }
}

function xvs {
    param(
        [string]$Name = "FirstOrder"
    )

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
