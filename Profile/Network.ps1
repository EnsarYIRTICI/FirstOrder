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
    if ( -not (Assert-AdminRights-Windows) ) { return }

    # vEthernet adapter IP kontrolü
    $wifiEx = Get-NetIPConfiguration -InterfaceAlias "vEthernet ($WifiSwitch)" -ErrorAction SilentlyContinue
    $ethEx  = Get-NetIPConfiguration -InterfaceAlias "vEthernet ($EthSwitch)" -ErrorAction SilentlyContinue

    $wifiConnected = $wifiEx.IPv4Address -ne $null
    $ethConnected  = $ethEx.IPv4Address -ne $null

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
        Write-Host "❌ Ne vEthernet ($WifiSwitch) ne de ($EthSwitch) IP almış. Çıkılıyor." -ForegroundColor Red
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

function Remove-FullTunnel {
    param (
        [string]$NextHop = "10.8.0.1"
    )

    try {
        if ( -not (Assert-AdminRights-Windows) ) { return }

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
        if ( -not (Assert-AdminRights-Windows) ) { return }
        
        Write-Host "[+] DNS sunucusu ayarlanıyor: $NextHop" -ForegroundColor Cyan
        Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses @($NextHop)
        Write-Host "✅ DNS ayarı tamamlandı." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ DNS ayarlanırken hata oluştu: $_" -ForegroundColor Red
    }
}