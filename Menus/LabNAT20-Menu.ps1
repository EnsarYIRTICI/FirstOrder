. "$scriptDir\Functions\Core\IO.ps1"
. "$scriptDir\Functions\Windows\LabNAT.ps1"

function LabNAT20-Menu {
    if (-not $IsWindows) {
        Write-Host "❌ LabNAT20 menüsü sadece Windows'ta çalışır." -ForegroundColor Red
        return
    }

    $cfg = Get-LabNatConfig

    $menuItems = @(
        @{ Label = "Kur / Onar (Switch + Host IP + NAT + VM NIC + Guards)"; Action = { Setup-LabNat -Config $cfg } },
        @{ Label = "Sadece Switch+Host IP+NAT oluştur/onar"; Action = { Ensure-LabNatNetwork -Config $cfg; Show-LabNatStatus -Config $cfg } },
        @{ Label = "Tüm VM'lere '$($cfg.SwitchName)' adapter EKLE (2. NIC)"; Action = { Add-SwitchAdapterToVMs -Config $cfg; Show-LabNatStatus -Config $cfg } },
        @{ Label = "Guard bas (DHCP Guard / Router Guard / MAC spoof OFF)"; Action = { Apply-LabNatGuards -Config $cfg; Show-LabNatStatus -Config $cfg } },
        @{ Label = "Durumu Göster"; Action = { Show-LabNatStatus -Config $cfg } },
        @{ Label = "KALDIR (NAT + Host IP + Switch + VM adapterları)"; Action = {
            if (Ask-YesNo "⚠️  LabNAT20 tamamen silinsin mi?") {
                Remove-LabNatNetwork -Config $cfg
            }
        }}
    )

    Show-Menu -MenuItems $menuItems -Title "LabNAT20 Yönetim Menüsü"
}
