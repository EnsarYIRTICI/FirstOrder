# Kullanıcı dizinini dinamik al
$UserHome = $HOME  # PowerShell 7'de Windows/Linux/macOS hepsinde çalışır

# Uygulama yollarını dinamik tanımla
$Applications = @{
    "FirstOrder" = Join-Path $UserHome 'repo\powershell\FirstOrder'
    "SshConfig"  = Join-Path $UserHome '.ssh'
}


function xsh {
    param(
        [string]$N = "FirstOrder"
    )

    if ($IsWindows) {
        Ensure-TerminalReady

        if ($Applications.ContainsKey($N)) {
            $appPath = $Applications[$N]
            $scriptPath = Join-Path $appPath "Main.ps1"

            if (-not (Test-Path $scriptPath)) {
                Write-Error "Main.ps1 bulunamadı: $scriptPath"
                return
            }

            Start-Process wt.exe -Verb RunAs -ArgumentList "pwsh `"$scriptPath`""

        } else {
            Write-Host "Uygulama bulunamadı: $N" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Bu fonksiyon sadece Windows üzerinde çalışır." -ForegroundColor Red
    }
}

function xvs {
    param(
        [string]$N = "FirstOrder"
    )

    Ensure-VscodeReady

    if ($Applications.ContainsKey($N)) {
        code $Applications[$N]
    }
    else {
        Write-Host "Uygulama bulunamadı: $N" -ForegroundColor Red
    }
}

function xt {
    param(
        [string]$N = "FirstOrder"
    )

    if ($Applications.ContainsKey($N)) {
        cd $Applications[$N]
    }
    else {
        Write-Host "Uygulama bulunamadı: $N" -ForegroundColor Red
    }
}

function xtn {
    if ($IsWindows) {
        Ensure-TerminalReady

        wt -w 0 nt -d .
        
    }
    else {
        Write-Host "Bu fonksiyon sadece Windows üzerinde çalışır." -ForegroundColor Red
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
