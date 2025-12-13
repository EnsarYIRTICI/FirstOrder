# Menus/HyperV-Menu.ps1

. "$scriptDir\Functions\Core\IO.ps1"
. "$scriptDir\Functions\Windows\HyperV.ps1"

function HyperV-Menu {
    if (-not $IsWindows) {
        Write-Host "Hyper-V menüsü sadece Windows'ta kullanılabilir." -ForegroundColor Red
        return
    }

    Write-Host "`nHyper-V Ayarları" -ForegroundColor Green

    $menuItems = @(
        @{ Label = "Durumu Göster (Feature/PS Modülü)"; Action = { Show-HyperVStatus } },
        @{ Label = "Hyper-V Etkinleştir"; Action = {
            Enable-HyperVFeature
            if (Ask-YesNo "Yeniden başlatılsın mı? (Önerilir)") { Restart-Computer }
        }},
        @{ Label = "Hyper-V Devre Dışı Bırak"; Action = {
            Disable-HyperVFeature
            if (Ask-YesNo "Yeniden başlatılsın mı?") { Restart-Computer }
        }},
        @{ Label = "Varsayılan VM/VHD Yollarını Göster (Get-VMHost)"; Action = { Show-HyperVHostPaths } },
        @{ Label = "Varsayılan VM/VHD Yollarını Değiştir (Set-VMHost)"; Action = { Set-HyperVHostPathsInteractive } }
    )

    # Alt menüden çıkış = geri dön
    Show-Menu -MenuItems $menuItems -Title "Hyper-V Menüsü" -ExitKey "B" -Prompt "Seçiminiz" -PauseAfterAction
}
