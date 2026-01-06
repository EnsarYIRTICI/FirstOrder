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
