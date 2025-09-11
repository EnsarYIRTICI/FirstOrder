# Ağ arayüzü için metric değerini 1 olarak ayarlayan yardımcı fonksiyon
function Up-Metric {
    param(
        [string]$N = "Wi-Fi"   # Varsayılan olarak Wi-Fi arayüzü
    )

    # Önce adaptör var mı kontrol et
    $adapter = Get-NetAdapter -Name $N -ErrorAction SilentlyContinue

    if ($adapter) {
        # Arayüz bulunduysa metric değerini 1 yap
        netsh interface ipv4 set interface "$N" metric=1
        Write-Host "✅ '$N' arayüzü bulundu, metric 1 olarak ayarlandı."
    }
    else {
        # Arayüz yoksa sadece bilgi mesajı ver
        Write-Host "⚠️ '$N' arayüzü bulunamadı, metric değiştirilemedi." -ForegroundColor Yellow
    }
}


# Wi-Fi arayüzünün metric değerini günceller
function Up-Wifi-Metric {
    Up-Metric -N "Wi-Fi"
}

# Hyper-V sanal switch (Wi-Fi) metric değerini günceller
function Up-Wifi-Ex-Metric {
    Up-Metric -N "vEthernet (wifi-ext-switch)"
}

# Ethernet arayüzünün metric değerini günceller
function Up-Ethernet-Metric {
    Up-Metric -N "Ethernet"
}

# Hyper-V sanal switch (Ethernet) metric değerini günceller
function Up-Eth-Ex-Metric {
    Up-Metric -N "vEthernet (eth-ext-switch)"
}

# VPN bağlantısında split tunneling açıp kapatan fonksiyon
function Toggle-SplitTunnel {
    param (
        [string]$InterfaceAlias = "OpenVPN Data Channel Offload", # VPN adaptör adı
        [string]$VpnGateway = "10.8.0.1"                          # VPN Gateway IP adresi
    )

    # Yönetici hakları kontrolü
    if ( -not (Assert-AdminRights-Windows) ) { return }

    # Adaptör bilgilerini al
    $iface = Get-NetIPInterface -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $iface) {
        Write-Error "❌ Adaptör bulunamadı: '$InterfaceAlias'"
        return
    }

    $index = $iface.InterfaceIndex

    # Default route kontrolü
    $routeA = Get-NetRoute -DestinationPrefix "0.0.0.0/1" -InterfaceIndex $index -ErrorAction SilentlyContinue
    $routeB = Get-NetRoute -DestinationPrefix "128.0.0.0/1" -InterfaceIndex $index -ErrorAction SilentlyContinue

    # Eğer split tunnel aktifse kapat, değilse aç
    if ($routeA -and $routeB) {
        Write-Host "🔌 Split tunnel AÇILIYOR... (default rotalar kaldırılıyor)"
        Remove-NetRoute -InterfaceIndex $index -DestinationPrefix "0.0.0.0/1" -Confirm:$false
        Remove-NetRoute -InterfaceIndex $index -DestinationPrefix "128.0.0.0/1" -Confirm:$false
        Write-Host "✅ Split tunnel AKTİF"
    }
    else {
        Write-Host "🔒 Split tunnel KAPANIYOR... (default rotalar ekleniyor)"
        New-NetRoute -DestinationPrefix "0.0.0.0/1" -InterfaceIndex $index -NextHop $VpnGateway -Confirm:$false | Out-Null
        New-NetRoute -DestinationPrefix "128.0.0.0/1" -InterfaceIndex $index -NextHop $VpnGateway -Confirm:$false | Out-Null
        Write-Host "✅ Tüm trafik VPN'e yönlendirildi (split tunnel PASİF)"
    }
}
