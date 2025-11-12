
function xNest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
         [Alias("n")]
        [string]$Name,

        # -Disable dersen kapatır
        [switch]$Disable
    )

    # Yönetici hakları kontrolü (gerekli, yoksa çıkış)
    if ( -not (Assert-AdminRights-Windows) ) {
        Write-Host "❌ Bu işlemi gerçekleştirmek için yönetici haklarına sahip olmalısınız." -ForegroundColor Red
        return
    }


    if ($Disable) {
        Set-VMProcessor -VMName $Name -ExposeVirtualizationExtensions $false
        Write-Host "Nested virtualization disabled for VM '$Name'."
    }
    else {
        Set-VMProcessor -VMName $Name -ExposeVirtualizationExtensions $true
        Write-Host "Nested virtualization enabled for VM '$Name'."
    }
}

function Restart-RunningVMs {
    # Yönetici hakları kontrolü (gerekli, yoksa çıkış)
    if ( -not (Assert-AdminRights-Windows) ) {
        Write-Host "❌ Bu işlemi gerçekleştirmek için yönetici haklarına sahip olmalısınız." -ForegroundColor Red
        return
    }

    Get-VM | Where-Object { $_.State -eq 'Running' } | Restart-VM -Force
}


function Get-RunningVMIPs {
    # Yönetici hakları kontrolü (gerekli, yoksa çıkış)
    if ( -not (Assert-AdminRights-Windows) ) {
        Write-Host "❌ Bu işlemi gerçekleştirmek için yönetici haklarına sahip olmalısınız." -ForegroundColor Red
        return
    }

    $vms = Get-VM | Where-Object { $_.State -eq 'Running' }

    if (-not $vms) {
        Write-Host "⚠️ Şu anda açık olan VM yok." -ForegroundColor Yellow
        return
    }

    $vms | Get-VMNetworkAdapter |
        Select-Object VMName, SwitchName,
            @{Name='IPAddresses';Expression={ ($_.IPAddresses | Where-Object {$_}) -join ', ' }} |
        Format-Table -AutoSize
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

    function Is-VMSwitchAdapterConnected($netConfig) {
        return $netConfig -and
            $netConfig.IPv4Address -and
            $netConfig.IPv4Address.IPAddress -match '\d+\.\d+\.\d+\.\d+' -and
            $netConfig.NetAdapter.MediaConnectionState -eq 'Connected'
    }

    $wifiAdapter = Get-NetAdapter -Name "vEthernet ($WifiSwitch)" -ErrorAction SilentlyContinue
    $ethAdapter  = Get-NetAdapter -Name "vEthernet ($EthSwitch)"  -ErrorAction SilentlyContinue

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

    Write-Host "`n📡 Adapter Durumları:"
    Write-Host "  - vEthernet ($WifiSwitch): " -NoNewline
    if ($wifiEx) { Write-Host "$($wifiEx.IPv4Address.IPAddress) (MediaStatus: $($wifiEx.NetAdapter.MediaConnectionState))" } else { Write-Host "Bulunamadı." }

    Write-Host "  - vEthernet ($EthSwitch): " -NoNewline
    if ($ethEx) { Write-Host "$($ethEx.IPv4Address.IPAddress) (MediaStatus: $($ethEx.NetAdapter.MediaConnectionState))" } else { Write-Host "Bulunamadı." }

    $wifiConnected = Is-VMSwitchAdapterConnected $wifiEx
    $ethConnected  = Is-VMSwitchAdapterConnected $ethEx

    if ($wifiConnected) {
        # Wi-Fi bağlı -> Ethernet VE Default Switch'teki VM'ler Wi-Fi switch'e
        Write-Host "`n💡 vEthernet ($WifiSwitch) bağlı. $EthSwitch ve $DefaultSwitch'e bağlı olan VM'ler $WifiSwitch'e geçirilecek.`n"
        $targetSwitch   = $WifiSwitch
        $sourceSwitches = @($EthSwitch, $DefaultSwitch)   # ✅ CHANGED
        Up-Wifi-Ex-Metric
    }
    elseif ($ethConnected) {
        # Ethernet bağlı -> Wi-Fi VE Default Switch'teki VM'ler Ethernet switch'e
        Write-Host "`n💡 vEthernet ($EthSwitch) bağlı. $WifiSwitch ve $DefaultSwitch'e bağlı olan VM'ler $EthSwitch'e geçirilecek.`n"
        $targetSwitch   = $EthSwitch
        $sourceSwitches = @($WifiSwitch, $DefaultSwitch)  # ✅ CHANGED
        Up-Eth-Ex-Metric
    }
    else {
        # Hiçbiri bağlı değil -> her şey Default Switch'e
        Write-Host "`n⚠️ Wi-Fi veya Ethernet bağlı değil. VM'ler $DefaultSwitch'e geçirilecek." -ForegroundColor Yellow
        $targetSwitch   = $DefaultSwitch
        $sourceSwitches = @($WifiSwitch, $EthSwitch)
    }

    $vms = Get-VM
    foreach ($vm in $vms) {
        $adapters = Get-VMNetworkAdapter -VMName $vm.Name
        foreach ($adapter in $adapters) {
            if ( ($sourceSwitches -contains $adapter.SwitchName) -and ($adapter.SwitchName -ne $targetSwitch) ) {
                Write-Host "🔄 VM '$($vm.Name)' $($adapter.SwitchName)'ten $targetSwitch'e geçiriliyor..."
                Connect-VMNetworkAdapter -VMName $vm.Name -SwitchName $targetSwitch
            } else {
                Write-Host "✔️  VM '$($vm.Name)' zaten doğru switch'e bağlı ($($adapter.SwitchName)). Atlanıyor."
            }
        }
    }

    Write-Host "`n✅ VM adapter'ları ve metrikler güncellendi."
}
