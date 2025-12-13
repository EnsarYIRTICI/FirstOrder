. "$scriptDir\Functions\Core\IO.ps1"
. "$scriptDir\Functions\Windows\WSL.ps1"

function WSL-Menu {
    if (-not $IsWindows) {
        Write-Host "❌ WSL menüsü sadece Windows'ta çalışır." -ForegroundColor Red
        return
    }

    $menuItems = @(
        @{ Label = "Durum Göster (Features / Default Version)"; Action = {
            $s = Get-WSLStatus
            Write-Host "`n=== WSL Durum ===" -ForegroundColor Green
            Write-Host "wsl komutu: $($s.WslCommand)"
            Write-Host "WSL Feature: $($s.WslFeature)"
            Write-Host "VirtualMachinePlatform: $($s.VmPlatform)"
            Write-Host "Default Version: $($s.DefaultVersion)"
        }},
        @{ Label = "WSL Etkinleştir (WSL + VirtualMachinePlatform)"; Action = { Enable-WSL } },
        @{ Label = "WSL Kapat (WSL + VirtualMachinePlatform)"; Action = { Disable-WSL } },
        @{ Label = "WSL Kernel Güncelle"; Action = { Update-WSLKernel } },
        @{ Label = "Default WSL Version = 2"; Action = { Set-WSLDefaultVersion -Version 2 } },
        @{ Label = "Default WSL Version = 1"; Action = { Set-WSLDefaultVersion -Version 1 } },
        @{ Label = "Distro Listele (wsl -l -v)"; Action = { Show-WSLDistros } },
        @{ Label = "WSL Shutdown (wsl --shutdown)"; Action = { Shutdown-WSL } },
        @{ Label = ".wslconfig oluştur (settings.json -> .wslconfig)"; Action = { Create-WslConfig } },
        @{ Label = ".wslconfig aç (Notepad)"; Action = { Open-WslConfig } }
    )

    Show-Menu -MenuItems $menuItems -Title "WSL Yönetim Menüsü"
}
