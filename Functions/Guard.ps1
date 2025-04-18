function Assert-AdminRights {
    if ($IsWindows) {
        $IsAdmin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'
        if (-not $IsAdmin) {
            Write-Host "Bu script'in Windows'ta yönetici olarak çalıştırılması gerekiyor!" -ForegroundColor Red
            Exit 1
        }
    }
    elseif ($IsLinux) {
        if ($env:SUDO_USER -eq $null) {
            Write-Host "Bu script'in Linux'ta root olarak çalıştırılması gerekiyor (sudo kullanın)!" -ForegroundColor Red
            Exit 1
        }
    }
    elseif ($IsMacOS) {
        $user = whoami
        if ($user -ne "root") {
            Write-Host "Bu script'in macOS'ta root olarak çalıştırılması gerekiyor (sudo kullanın)!" -ForegroundColor Red
            Exit 1
        }
    }

}   