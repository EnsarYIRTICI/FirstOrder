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

function Use-VpnDNS {
    param(
        [string]$InterfaceAlias = "OpenVPN Data Channel Offload",
        [string[]]$DnsServers = @("10.8.0.1"),
        [int]$Metric = 5
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    # VPN adaptörüne DNS ver
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DnsServers

    # DNS seçimini etkileyebilecek şekilde metrik düşür
    Set-NetIPInterface -InterfaceAlias $InterfaceAlias -InterfaceMetric $Metric -ErrorAction SilentlyContinue

    Clear-DnsClientCache
    Write-Host "✅ VPN DNS ayarlandı: $($DnsServers -join ', ') | Metric: $Metric"
}

function Enable-SplitDNS {
    param(
        [string[]]$InternalDomains = @("pi","msi"),
        [string[]]$VpnDns = @("10.8.0.1")
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    foreach ($d in $InternalDomains) {
        $ns = ".$d"

        # Aynı namespace için eski kural varsa temizle
        Get-DnsClientNrptRule -ErrorAction SilentlyContinue |
            Where-Object { $_.Namespace -eq $ns } |
            Remove-DnsClientNrptRule -Force -ErrorAction SilentlyContinue

        # Yeni kuralı ekle
        Add-DnsClientNrptRule -Namespace $ns -NameServers $VpnDns

        Write-Host "✅ Split DNS aktif: *$ns -> $($VpnDns -join ', ')"
    }

    Clear-DnsClientCache
}

function Disable-SplitDNS {
    param(
        [string[]]$InternalDomains = @("pi","msi")
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    foreach ($d in $InternalDomains) {
        $ns = ".$d"

        Get-DnsClientNrptRule -ErrorAction SilentlyContinue |
            Where-Object { $_.Namespace -eq $ns } |
            Remove-DnsClientNrptRule -Force -ErrorAction SilentlyContinue

        Write-Host "✅ Split DNS kaldırıldı: *$ns"
    }

    Clear-DnsClientCache
}