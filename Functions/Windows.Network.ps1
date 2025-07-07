function Remove-FullTunnel {
    param (
        [string]$NextHop = "10.8.0.1"
    )

    try {
        Write-Host "`n[+] Full-Tunnel rotaları temizleniyor..." -ForegroundColor Yellow
        Remove-NetRoute -DestinationPrefix "128.0.0.0/1" -NextHop $NextHop -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -DestinationPrefix "0.0.0.0/1" -NextHop $NextHop -Confirm:$false -ErrorAction SilentlyContinue

        Write-Host "`n✅ Full-Tunnel yapılandırması kaldırıldı." -ForegroundColor Green
    }
    catch {
        Write-Host "`n❌ Bir şeyler ters gitti: $_" -ForegroundColor Red
    }
}

function Set-DNS {
    param (
        [string]$NextHop = "192.168.1.1, 10.8.0.1",
        [string]$InterfaceAlias = "vEthernet (wifi-ext-switch)"
    )

    try {
        Write-Host "[+] DNS sunucusu ayarlanıyor: $NextHop" -ForegroundColor Cyan
        Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses @($NextHop)
        Write-Host "✅ DNS ayarı tamamlandı." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ DNS ayarlanırken hata oluştu: $_" -ForegroundColor Red
    }
}