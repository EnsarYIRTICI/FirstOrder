function Up-Metric  {
    param(
        [string]$N = "Wi-Fi"
    )

    netsh interface ipv4 set interface "$N" metric=1
}

function Up-Wifi-Metric {
    Up-Metric -N "Wi-Fi"
}

function Up-Wifi-Ex-Metric {
    Up-Metric -N "vEthernet (wifi-ext-switch)"
}

function Up-Ethernet-Metric {
    Up-Metric -N "Ethernet"
}

function Up-Eth-Ex-Metric {
    Up-Metric -N "vEthernet (eth-ext-switch)"
}

function Switch-VMSwitch-ByConnection {
    param (
        [string]$WifiSwitch = "wifi-ext-switch",
        [string]$EthSwitch  = "eth-ext-switch"
    )

    # Admin kontrolü
    if ( -not (Assert-AdminRights-Windows) ) {
        Write-Host "❌ Bu işlemi gerçekleştirmek için yönetici haklarına sahip olmalısınız." -ForegroundColor Red
        return
    }

    function Is-VMSwitchAdapterConnected($netConfig) {
        return $netConfig -and
            $netConfig.IPv4Address -and
            $netConfig.IPv4Address.IPAddress -match '\d+\.\d+\.\d+\.\d+' -and
            $netConfig.NetAdapter.MediaConnectionState -eq 'Connected'
    }

    # Adapter bilgilerini al
    $wifiEx = Get-NetIPConfiguration -InterfaceAlias "vEthernet ($WifiSwitch)" -ErrorAction SilentlyContinue
    $ethEx  = Get-NetIPConfiguration -InterfaceAlias "vEthernet ($EthSwitch)" -ErrorAction SilentlyContinue

    # Durumları yazdır
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

    # Hangi adapter bağlı?
    $wifiConnected = Is-VMSwitchAdapterConnected $wifiEx
    $ethConnected  = Is-VMSwitchAdapterConnected $ethEx

    if ($wifiConnected) {
        Write-Host "`n💡 vEthernet ($WifiSwitch) bağlı. $EthSwitch'e bağlı olan VM'ler $WifiSwitch'e geçirilecek.`n"
        $targetSwitch = $WifiSwitch
        $sourceSwitch = $EthSwitch

        Up-Wifi-Ex-Metric

    } elseif ($ethConnected) {
        Write-Host "`n💡 vEthernet ($EthSwitch) bağlı. $WifiSwitch'e bağlı olan VM'ler $EthSwitch'e geçirilecek.`n"
        $targetSwitch = $EthSwitch
        $sourceSwitch = $WifiSwitch

        Up-Eth-Ex-Metric

    } else {
        Write-Host "`n❌ Ne vEthernet ($WifiSwitch) ne de ($EthSwitch) bağlı veya IP almış. Çıkılıyor." -ForegroundColor Red
        return
    }

    # VM’leri kontrol et ve switch değiştir
    $vms = Get-VM

    foreach ($vm in $vms) {
        $adapters = Get-VMNetworkAdapter -VMName $vm.Name

        foreach ($adapter in $adapters) {
            if ($adapter.SwitchName -eq $sourceSwitch) {
                Write-Host "🔄 VM '$($vm.Name)' $sourceSwitch'ten $targetSwitch'e geçiriliyor..."
                Connect-VMNetworkAdapter -VMName $vm.Name -SwitchName $targetSwitch
            } else {
                Write-Host "✔️  VM '$($vm.Name)' zaten doğru switch'e bağlı ($($adapter.SwitchName)). Atlanıyor."
            }
        }
    }

    Write-Host "`n✅ VM adapter'ları ve metrikler güncellendi."
}


function Toggle-SplitTunnel {
    param (
        [string]$InterfaceAlias = "OpenVPN Data Channel Offload",
        [string]$VpnGateway = "10.8.0.1"
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    # InterfaceIndex'i InterfaceAlias'a göre al (ilk eşleşeni)
    $iface = Get-NetIPInterface -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $iface) {
        Write-Error "❌ Adaptör bulunamadı: '$InterfaceAlias'"
        return
    }

    $index = $iface.InterfaceIndex

    # Route kontrol
    $routeA = Get-NetRoute -DestinationPrefix "0.0.0.0/1" -InterfaceIndex $index -ErrorAction SilentlyContinue
    $routeB = Get-NetRoute -DestinationPrefix "128.0.0.0/1" -InterfaceIndex $index -ErrorAction SilentlyContinue

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

