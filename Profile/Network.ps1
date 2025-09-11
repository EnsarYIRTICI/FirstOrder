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

# VM'lerin bağlı olduğu sanal switch'i, aktif olan fiziksel bağlantıya göre otomatik değiştirir.
# Öncelik sırası: Wi-Fi > Ethernet > Default Switch (fallback)
function Switch-VMSwitch-ByConnection {
    param (
        [string]$WifiSwitch    = "wifi-ext-switch", # Wi-Fi sanal switch adı
        [string]$EthSwitch     = "eth-ext-switch",  # Ethernet sanal switch adı
        [string]$DefaultSwitch = "Default Switch"   # Fallback switch adı
    )

    # Yönetici hakları kontrolü (gerekli, yoksa çıkış)
    if ( -not (Assert-AdminRights-Windows) ) {
        Write-Host "❌ Bu işlemi gerçekleştirmek için yönetici haklarına sahip olmalısınız." -ForegroundColor Red
        return
    }

    # Yardımcı fonksiyon: adaptör bağlı mı ve geçerli bir IPv4 adresi almış mı kontrol eder
    function Is-VMSwitchAdapterConnected($netConfig) {
        return $netConfig -and
            $netConfig.IPv4Address -and
            $netConfig.IPv4Address.IPAddress -match '\d+\.\d+\.\d+\.\d+' -and
            $netConfig.NetAdapter.MediaConnectionState -eq 'Connected'
    }

    # --- Adaptör var mı kontrol et (hata mesajını engellemek için) ---
    $wifiAdapter = Get-NetAdapter -Name "vEthernet ($WifiSwitch)" -ErrorAction SilentlyContinue
    $ethAdapter  = Get-NetAdapter -Name "vEthernet ($EthSwitch)"  -ErrorAction SilentlyContinue

    # Eğer adaptör varsa IP konfigürasyonunu al, yoksa null ata
    if ($wifiAdapter) {
        $wifiEx = Get-NetIPConfiguration -InterfaceAlias "vEthernet ($WifiSwitch)" -ErrorAction SilentlyContinue 2>$null
    } else {
        $wifiEx = $null
    }

    if ($ethAdapter) {
        $ethEx  = Get-NetIPConfiguration -InterfaceAlias "vEthernet ($EthSwitch)"  -ErrorAction SilentlyContinue 2>$null
    } else {
        $ethEx = $null
    }
    # ---------------------------------------------------------------

    # Mevcut durumları ekrana yazdır
    Write-Host "`n📡 Adapter Durumları:"
    Write-Host "  - vEthernet ($WifiSwitch): " -NoNewline
    if ($wifiEx) {
        Write-Host "$($wifiEx.IPv4Address.IPAddress) (MediaStatus: $($wifiEx.NetAdapter.MediaConnectionState))"
    } else {
        Write-Host "Bulunamadı."
    }

    Write-Host "  - vEthernet ($EthSwitch): " -NoNewline
    if ($ethEx) {
        Write-Host "$($ethEx.IPv4Address.IPAddress) (MediaStatus: $($ethEx.NetAdapter.MediaConnectionState))"
    } else {
        Write-Host "Bulunamadı."
    }

    # Bağlı olan adaptörü belirle
    $wifiConnected = Is-VMSwitchAdapterConnected $wifiEx
    $ethConnected  = Is-VMSwitchAdapterConnected $ethEx

    if ($wifiConnected) {
        # Wi-Fi adaptörü bağlı -> Ethernet tarafındaki VM'ler Wi-Fi switch'e aktarılacak
        Write-Host "`n💡 vEthernet ($WifiSwitch) bağlı. $EthSwitch'e bağlı olan VM'ler $WifiSwitch'e geçirilecek.`n"
        $targetSwitch   = $WifiSwitch
        $sourceSwitches = @($EthSwitch)

        # Metric güncelle
        Up-Wifi-Ex-Metric
    }
    elseif ($ethConnected) {
        # Ethernet adaptörü bağlı -> Wi-Fi tarafındaki VM'ler Ethernet switch'e aktarılacak
        Write-Host "`n💡 vEthernet ($EthSwitch) bağlı. $WifiSwitch'e bağlı olan VM'ler $EthSwitch'e geçirilecek.`n"
        $targetSwitch   = $EthSwitch
        $sourceSwitches = @($WifiSwitch)

        # Metric güncelle
        Up-Eth-Ex-Metric
    }
    else {
        # Hiçbiri bağlı değil -> VM'ler Default Switch'e geçirilecek (fallback senaryo)
        Write-Host "`n⚠️ Wi-Fi veya Ethernet bağlı değil. VM'ler $DefaultSwitch'e geçirilecek." -ForegroundColor Yellow
        $targetSwitch   = $DefaultSwitch
        $sourceSwitches = @($WifiSwitch, $EthSwitch)
    }

    # VM'ler üzerinde dolaşarak network adaptörlerini kontrol et
    $vms = Get-VM
    foreach ($vm in $vms) {
        $adapters = Get-VMNetworkAdapter -VMName $vm.Name
        foreach ($adapter in $adapters) {
            # Eğer VM yanlış switch'e bağlıysa hedef switch'e geçir
            if ( ($sourceSwitches -contains $adapter.SwitchName) -and ($adapter.SwitchName -ne $targetSwitch) ) {
                Write-Host "🔄 VM '$($vm.Name)' $($adapter.SwitchName)'ten $targetSwitch'e geçiriliyor..."
                Connect-VMNetworkAdapter -VMName $vm.Name -SwitchName $targetSwitch
            } else {
                # Zaten doğru switch'te ise atla
                Write-Host "✔️  VM '$($vm.Name)' zaten doğru switch'e bağlı ($($adapter.SwitchName)). Atlanıyor."
            }
        }
    }

    Write-Host "`n✅ VM adapter'ları ve metrikler güncellendi."
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
