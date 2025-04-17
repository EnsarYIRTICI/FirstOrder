function Assert-AdminRights {
    if (-not ($IsWindows -or $IsLinux -or $IsMacOS)) {
        $IsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
        $IsLinux = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)
        $IsMacOS = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)
    }

    if ($IsWindows) {
        $IsAdmin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'
        if (-not $IsAdmin) {
            Write-Host "Bu script'in Windows'ta yönetici olarak çalıştırılması gerekiyor!"
            Exit 1
        }
    }
    elseif ($IsLinux) {
        if ($env:SUDO_USER -eq $null) {
            Write-Host "Bu script'in Linux'ta root olarak çalıştırılması gerekiyor (sudo kullanın)!"
            Exit 1
        }
    }
    elseif ($IsMacOS) {
        $user = whoami
        if ($user -ne "root") {
            Write-Host "Bu script'in macOS'ta root olarak çalıştırılması gerekiyor (sudo kullanın)!"
            Exit 1
        }
    }

}   