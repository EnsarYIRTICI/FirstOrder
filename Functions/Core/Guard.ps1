function Detect-OS {
    if (-not ($IsWindows -or $IsLinux -or $IsMacOS)) {
        try {
            $global:IsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)            
            $global:IsLinux = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)
            $global:IsMacOS = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)

        } catch {
            if (-not ($IsWindows -or $IsLinux -or $IsMacOS)) {
                Write-Host "OS Kontrol Hatası:"
                Exit 1
            }
        }
    }
}

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
            Write-Host "Bu script'in Linux'ta root olarak çalıştırılması gerekiyor (sudo pwsh ./Main.ps1)!" -ForegroundColor Red
            Exit 1
        }
    }
    elseif ($IsMacOS) {
        $user = whoami
        if ($user -ne "root") {
            Write-Host "Bu script'in macOS'ta root olarak çalıştırılması gerekiyor (sudo pwsh ./Main.ps1)!" -ForegroundColor Red
            Exit 1
        }
    }
    else {
        Write-Host "Desteklenmeyen işletim sistemi." -ForegroundColor Red
        Exit 1
    }
}   