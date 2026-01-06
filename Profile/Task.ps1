function xKill {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias("p")]
        [int]$Port
    )

    # Burada toplayacağımız process ID'ler olacak
    $procIds = @()

    # 1) Modern yol: Get-NetTCPConnection
    try {
        $conns = Get-NetTCPConnection -LocalPort $Port -ErrorAction Stop
        if ($conns) {
            $procIds = $conns | Select-Object -ExpandProperty OwningProcess -Unique
        }
    }
    catch {
        # Buraya düşersek birazdan netstat ile devam edeceğiz
    }

    # 2) Eğer hala PID bulamadıysak eski yöntem: netstat
    if (-not $procIds -or $procIds.Count -eq 0) {
        $lines = netstat -ano | Select-String ":$Port\s"
        if (-not $lines) {
            Write-Warning "Port $Port üzerinde dinleyen bir process bulunamadı."
            return
        }

        $tmpIds = @()
        foreach ($line in $lines) {
            # satırı parçala, son eleman PID
            $parts = $line.ToString().Trim() -split '\s+'
            $tmpIds += $parts[-1]
        }
        $procIds = $tmpIds | Select-Object -Unique
    }

    foreach ($procId in $procIds) {
        try {
            $proc = Get-Process -Id $procId -ErrorAction Stop
            Write-Host "Port $Port'u kullanan process: $($proc.ProcessName) (PID: $procId). Kapatılıyor..." -ForegroundColor Yellow
            Stop-Process -Id $procId -Force
            Write-Host "PID $procId kapatıldı." -ForegroundColor Green
        }
        catch {
            Write-Warning "PID $procId kapatılamadı: $($_.Exception.Message)"
        }
    }
}
