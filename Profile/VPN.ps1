function Enable-SplitTunnel {
    param(
        [string]$InterfaceAlias = "OpenVPN Data Channel Offload",
        [switch]$HandleIPv6 = $true
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    $iface = Get-NetIPInterface -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $iface) { Write-Error "❌ Adaptör bulunamadı: '$InterfaceAlias'"; return }

    $index = $iface.InterfaceIndex

    # IPv4 full izlerini temizle
    "0.0.0.0/1","128.0.0.0/1","0.0.0.0/0" | ForEach-Object {
        Get-NetRoute -InterfaceIndex $index -DestinationPrefix $_ -ErrorAction SilentlyContinue |
            Remove-NetRoute -Confirm:$false
    }

    # IPv6 default temizle
    if ($HandleIPv6) {
        Get-NetRoute -InterfaceIndex $index -DestinationPrefix "::/0" -ErrorAction SilentlyContinue |
            Remove-NetRoute -Confirm:$false
    }

    Write-Host "✅ Split tunnel zorla aktif edildi."
}

function Disable-SplitTunnel {
    param(
        [string]$InterfaceAlias = "OpenVPN Data Channel Offload",
        [string]$VpnGateway = "10.8.0.1"
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    $iface = Get-NetIPInterface -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $iface) { Write-Error "❌ Adaptör bulunamadı: '$InterfaceAlias'"; return }

    $index = $iface.InterfaceIndex

    if (-not (Get-NetRoute -DestinationPrefix "0.0.0.0/1" -InterfaceIndex $index -ErrorAction SilentlyContinue)) {
        New-NetRoute -DestinationPrefix "0.0.0.0/1" -InterfaceIndex $index -NextHop $VpnGateway -Confirm:$false | Out-Null
    }
    if (-not (Get-NetRoute -DestinationPrefix "128.0.0.0/1" -InterfaceIndex $index -ErrorAction SilentlyContinue)) {
        New-NetRoute -DestinationPrefix "128.0.0.0/1" -InterfaceIndex $index -NextHop $VpnGateway -Confirm:$false | Out-Null
    }

    Write-Host "✅ Full tunnel (def1) aktif edildi."
}

function Enable-VpnDNS {
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
    Write-Host "✅ VPN DNS ENABLED: $($DnsServers -join ', ') | Metric: $Metric"
}

function Disable-VpnDNS {
    param(
        [string]$InterfaceAlias = "OpenVPN Data Channel Offload",
        [switch]$ResetMetricToAuto = $true,
        [int]$Metric = 50  # Auto istemezsen fallback sabit metric
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    # DNS'i sıfırla (DHCP/varsayılan davranışa döner)
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ResetServerAddresses

    # Metric'i otomatiğe döndür ya da güvenli bir değere çek
    if ($ResetMetricToAuto) {
        Set-NetIPInterface -InterfaceAlias $InterfaceAlias -AutomaticMetric Enabled -ErrorAction SilentlyContinue
    }
    else {
        Set-NetIPInterface -InterfaceAlias $InterfaceAlias -InterfaceMetric $Metric -ErrorAction SilentlyContinue
    }

    Clear-DnsClientCache
    Write-Host "✅ VPN DNS DISABLED: DNS resetlendi" +
               ($(if($ResetMetricToAuto){" | Metric: Auto"} else {" | Metric: $Metric"}))
}

function Enable-VpnDnsForTlds {
    param(
        [string[]]$Tlds = @("pi","msi"),
        [string[]]$VpnDns = @("10.8.0.1")
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    foreach ($t in $Tlds) {
        $ns = ".$t"

        # Eski kural varsa temizle
        Get-DnsClientNrptRule -ErrorAction SilentlyContinue |
            Where-Object { $_.Namespace -eq $ns } |
            Remove-DnsClientNrptRule -Force -ErrorAction SilentlyContinue

        # Yeni kuralı ekle
        Add-DnsClientNrptRule -Namespace $ns -NameServers $VpnDns

        Write-Host "✅ VPN DNS kuralı: *$ns -> $($VpnDns -join ', ')"
    }

    Clear-DnsClientCache
}

function Disable-VpnDnsForTlds {
    param(
        [string[]]$Tlds = @("pi","msi")
    )

    if ( -not (Assert-AdminRights-Windows) ) { return }

    foreach ($t in $Tlds) {
        $ns = ".$t"

        Get-DnsClientNrptRule -ErrorAction SilentlyContinue |
            Where-Object { $_.Namespace -eq $ns } |
            Remove-DnsClientNrptRule -Force -ErrorAction SilentlyContinue

        Write-Host "✅ Kural kaldırıldı: *$ns"
    }

    Clear-DnsClientCache
}
