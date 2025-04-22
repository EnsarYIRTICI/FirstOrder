function First-Order {
    Ensure-TerminalReady

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
