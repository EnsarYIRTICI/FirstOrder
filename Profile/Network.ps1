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

