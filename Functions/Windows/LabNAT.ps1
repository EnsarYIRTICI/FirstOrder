function Get-LabNatConfig {
    # settings.json'da labnat20 varsa onu kullan, yoksa defaultlar
    $defaults = [ordered]@{
        SwitchName           = "LabNAT20"
        NatName              = "LabNAT20"
        PrefixCidr           = "10.77.0.0/20"
        GatewayIP            = "10.77.0.1"
        PrefixLength         = 20
        DhcpVmName           = "Ubuntu Server DHCP"
        AdapterNamePrefix    = "extra"

        # RouterGuard'ı KAPALI bırakmak isteyebileceğin VM'ler (subnet router vs.)
        RouterGuardExemptVMs = @("Ubuntu Server Tailscale", "Ubuntu Server OpenVPN")

        # Lab switch 2. NIC eklenirken hariç tutmak istersen
        ExcludeAddAdapterVMs = @()
    }

    try {
        $json = Get-SettingsJSON
        if ($json -and $json.labnat20) {
            $cfg = $json.labnat20
            return [ordered]@{
                SwitchName           = $cfg.switch_name           ?? $defaults.SwitchName
                NatName              = $cfg.nat_name              ?? $defaults.NatName
                PrefixCidr           = $cfg.prefix                ?? $defaults.PrefixCidr
                GatewayIP            = $cfg.gateway_ip            ?? $defaults.GatewayIP
                PrefixLength         = $cfg.prefix_length         ?? $defaults.PrefixLength
                DhcpVmName           = $cfg.dhcp_vm               ?? $defaults.DhcpVmName
                AdapterNamePrefix    = $cfg.adapter_name_prefix   ?? $defaults.AdapterNamePrefix
                RouterGuardExemptVMs = $cfg.router_exempt_vms      ?? $defaults.RouterGuardExemptVMs
                ExcludeAddAdapterVMs = $cfg.exclude_add_adapter_vms ?? $defaults.ExcludeAddAdapterVMs
            }
        }
    } catch {
        # settings yoksa sessizce default
    }

    return $defaults
}

function Ensure-LabNatNetwork {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)][hashtable]$Config
    )

    $switchName = $Config.SwitchName
    $natName    = $Config.NatName
    $prefixCidr = $Config.PrefixCidr
    $gwIP       = $Config.GatewayIP
    $pl         = [int]$Config.PrefixLength

    # 1) vSwitch
    $sw = Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue
    if (-not $sw) {
        if ($PSCmdlet.ShouldProcess($switchName, "New-VMSwitch Internal")) {
            Write-Host "🧱 vSwitch oluşturuluyor: $switchName (Internal)" -ForegroundColor Cyan
            New-VMSwitch -Name $switchName -SwitchType Internal | Out-Null
        }
    } else {
        if ($sw.SwitchType -ne "Internal") {
            Write-Host "⚠️  '$switchName' var ama SwitchType=$($sw.SwitchType). Internal bekliyorduk." -ForegroundColor Yellow
        } else {
            Write-Host "✔️  vSwitch hazır: $switchName" -ForegroundColor Green
        }
    }

    # 2) Host vEthernet IP
    $ifAlias = "vEthernet ($switchName)"
    $ipList = Get-NetIPAddress -InterfaceAlias $ifAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue
    $hasGw  = $false

    if ($ipList) {
        $hasGw = $ipList.IPAddress -contains $gwIP
    }

    if (-not $hasGw) {
        if ($ipList) {
            if ($PSCmdlet.ShouldProcess($ifAlias, "Remove existing IPv4 on $ifAlias")) {
                Write-Host "🧹 Host vEthernet üzerinde eski IPv4'ler temizleniyor: $ifAlias" -ForegroundColor Yellow
                $ipList | Remove-NetIPAddress -Confirm:$false
            }
        }

        if ($PSCmdlet.ShouldProcess($ifAlias, "Assign $gwIP/$pl")) {
            Write-Host "🌐 Host gateway IP veriliyor: $ifAlias = $gwIP/$pl" -ForegroundColor Cyan
            New-NetIPAddress -InterfaceAlias $ifAlias -IPAddress $gwIP -PrefixLength $pl | Out-Null
        }
    } else {
        Write-Host "✔️  Host gateway IP hazır: $ifAlias = $gwIP/$pl" -ForegroundColor Green
    }

    # 3) NAT
    $nat = Get-NetNat -Name $natName -ErrorAction SilentlyContinue
    if ($nat) {
        if ($nat.InternalIPInterfaceAddressPrefix -ne $prefixCidr) {
            Write-Host "⚠️  NAT '$natName' var ama prefix farklı: $($nat.InternalIPInterfaceAddressPrefix) != $prefixCidr" -ForegroundColor Yellow
            if ($PSCmdlet.ShouldProcess($natName, "Recreate NAT with $prefixCidr")) {
                Remove-NetNat -Name $natName -Confirm:$false
                New-NetNat -Name $natName -InternalIPInterfaceAddressPrefix $prefixCidr | Out-Null
            }
        } else {
            Write-Host "✔️  NAT hazır: $natName ($prefixCidr)" -ForegroundColor Green
        }
    } else {
        if ($PSCmdlet.ShouldProcess($natName, "New-NetNat $prefixCidr")) {
            Write-Host "🔥 NAT oluşturuluyor: $natName ($prefixCidr)" -ForegroundColor Cyan
            New-NetNat -Name $natName -InternalIPInterfaceAddressPrefix $prefixCidr | Out-Null
        }
    }
}

function Ensure-VMHasSwitchAdapter {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)][string]$VMName,
        [Parameter(Mandatory=$true)][string]$SwitchName,
        [Parameter(Mandatory=$true)][string]$AdapterNamePrefix
    )

    $adapters = Get-VMNetworkAdapter -VMName $VMName
    if ($adapters.SwitchName -contains $SwitchName) {
        Write-Host "✔️  '$VMName': zaten '$SwitchName' bağlı. Atlanıyor." -ForegroundColor DarkGreen
        return $false
    }

    # benzersiz nic adı
    $newName = $AdapterNamePrefix
    $i = 1
    while ($adapters.Name -contains $newName) {
        $i++
        $newName = "$AdapterNamePrefix$i"
    }

    $msg = "Add NIC '$newName' -> $SwitchName (mevcut switch'lere dokunma)"
    if ($PSCmdlet.ShouldProcess($VMName, $msg)) {
        try {
            Add-VMNetworkAdapter -VMName $VMName -SwitchName $SwitchName -Name $newName | Out-Null
            Write-Host "➕ $VMName : '$newName' eklendi -> $SwitchName" -ForegroundColor Cyan
            return $true
        } catch {
            Write-Host "❌ $VMName : NIC eklenemedi. (VM çalışıyorsa hot-add desteklemeyebilir) Hata: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }

    return $false
}

function Add-SwitchAdapterToVMs {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)][hashtable]$Config,
        [string[]]$VMName
    )

    $switchName = $Config.SwitchName
    $prefix     = $Config.AdapterNamePrefix
    $exclude    = @($Config.ExcludeAddAdapterVMs)

    $vms = if ($VMName) { Get-VM -Name $VMName -ErrorAction Stop } else { Get-VM }
    if ($exclude.Count -gt 0) {
        $vms = $vms | Where-Object { $exclude -notcontains $_.Name }
    }

    $added = 0
    foreach ($vm in $vms) {
        if ($vm.Name -eq $null -or $vm.Name -eq "") { continue }
        if ($PSCmdlet.ShouldProcess($vm.Name, "Ensure NIC on $switchName")) {
            $didAdd = Ensure-VMHasSwitchAdapter -VMName $vm.Name -SwitchName $switchName -AdapterNamePrefix $prefix
            if ($didAdd) { $added++ }
        }
    }

    Write-Host "`n✅ Toplam eklenen adapter: $added" -ForegroundColor Green
}

function Apply-LabNatGuards {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)][hashtable]$Config
    )

    $switchName = $Config.SwitchName
    $dhcpVm     = $Config.DhcpVmName
    $routerExempt = @($Config.RouterGuardExemptVMs)

    # DHCP sunucu VM'nin guard'larını garanti kapat
    try {
        $dhcpAdapters = Get-VMNetworkAdapter -VMName $dhcpVm -ErrorAction Stop | Where-Object { $_.SwitchName -eq $switchName }
        foreach ($a in $dhcpAdapters) {
            if ($PSCmdlet.ShouldProcess($dhcpVm, "Disable DhcpGuard/RouterGuard on DHCP server adapter '$($a.Name)'")) {
                Set-VMNetworkAdapter -VMName $dhcpVm -Name $a.Name -DhcpGuard Off -RouterGuard Off | Out-Null
                Write-Host "🛑 DHCP VM guard kapatıldı: $dhcpVm / $($a.Name)" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "⚠️  DHCP VM '$dhcpVm' bulunamadı ya da '$switchName' üzerinde adapter yok." -ForegroundColor Yellow
    }

    # Diğer VM'lerde DHCP Guard ON
    $targets = Get-VMNetworkAdapter -All |
        Where-Object {
            $_.SwitchName -eq $switchName -and
            -not $_.IsManagementOS -and
            $_.VMName -and
            $_.VMName -ne $dhcpVm
        }

    if ($PSCmdlet.ShouldProcess($switchName, "Enable DhcpGuard on VM adapters")) {
        $targets | Set-VMNetworkAdapter -DhcpGuard On | Out-Null
        Write-Host "🛡️  DHCP Guard ON basıldı (DHCP VM hariç)" -ForegroundColor Cyan
    }

    # Router Guard ON (exempt list hariç)
    $routerTargets = $targets | Where-Object { $routerExempt -notcontains $_.VMName }
    if ($PSCmdlet.ShouldProcess($switchName, "Enable RouterGuard on VM adapters (exempt: $($routerExempt -join ', '))")) {
        $routerTargets | Set-VMNetworkAdapter -RouterGuard On | Out-Null
        Write-Host "🛡️  Router Guard ON basıldı (exempt VM'ler hariç)" -ForegroundColor Cyan
    }

    # MAC spoofing Off (genelde iyi)
    if ($PSCmdlet.ShouldProcess($switchName, "Disable MAC spoofing on VM adapters")) {
        $targets | Set-VMNetworkAdapter -MacAddressSpoofing Off | Out-Null
        Write-Host "🔒 MAC spoofing OFF basıldı" -ForegroundColor Cyan
    }
}

function Show-LabNatStatus {
    param([Parameter(Mandatory=$true)][hashtable]$Config)

    $switchName = $Config.SwitchName
    $natName    = $Config.NatName
    $ifAlias    = "vEthernet ($switchName)"

    Write-Host "`n=== Lab NAT Durum ===" -ForegroundColor Green

    $sw = Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue
    if ($sw) {
        Write-Host "vSwitch: $switchName (Type=$($sw.SwitchType))" -ForegroundColor Green
    } else {
        Write-Host "vSwitch: $switchName (YOK)" -ForegroundColor Red
    }

    $ip = Get-NetIPAddress -InterfaceAlias $ifAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue
    if ($ip) {
        Write-Host "Host IP: $ifAlias -> $($ip.IPAddress -join ', ')/$($ip.PrefixLength | Select-Object -First 1)" -ForegroundColor Green
    } else {
        Write-Host "Host IP: $ifAlias -> (YOK)" -ForegroundColor Red
    }

    $nat = Get-NetNat -Name $natName -ErrorAction SilentlyContinue
    if ($nat) {
        Write-Host "NAT: $natName ($($nat.InternalIPInterfaceAddressPrefix)) Active=$($nat.Active)" -ForegroundColor Green
    } else {
        Write-Host "NAT: $natName (YOK)" -ForegroundColor Red
    }

    Write-Host "`n--- LabNAT20'ye bağlı VM adapter'ları ---" -ForegroundColor Cyan
    Get-VMNetworkAdapter -All |
        Where-Object { $_.SwitchName -eq $switchName -and -not $_.IsManagementOS } |
        Select VMName, Name, SwitchName, DhcpGuard, RouterGuard, MacAddressSpoofing |
        Sort VMName, Name |
        Format-Table -Auto
}

function Remove-LabNatNetwork {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([Parameter(Mandatory=$true)][hashtable]$Config)

    $switchName = $Config.SwitchName
    $natName    = $Config.NatName
    $ifAlias    = "vEthernet ($switchName)"

    # 1) VM tarafındaki bu switche bağlı adapterları kaldır (management os hariç)
    $adapters = Get-VMNetworkAdapter -All | Where-Object { $_.SwitchName -eq $switchName -and -not $_.IsManagementOS -and $_.VMName }
    foreach ($a in $adapters) {
        if ($PSCmdlet.ShouldProcess($a.VMName, "Remove adapter '$($a.Name)' from $switchName")) {
            try {
                Remove-VMNetworkAdapter -VMName $a.VMName -Name $a.Name -Confirm:$false
                Write-Host "🗑️  Adapter silindi: $($a.VMName) / $($a.Name)" -ForegroundColor Yellow
            } catch {
                Write-Host "⚠️  Adapter silinemedi: $($a.VMName) / $($a.Name) -> $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }

    # 2) NAT sil
    $nat = Get-NetNat -Name $natName -ErrorAction SilentlyContinue
    if ($nat -and $PSCmdlet.ShouldProcess($natName, "Remove-NetNat")) {
        Remove-NetNat -Name $natName -Confirm:$false
        Write-Host "🧨 NAT silindi: $natName" -ForegroundColor Yellow
    }

    # 3) Host IP sil
    $ip = Get-NetIPAddress -InterfaceAlias $ifAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue
    if ($ip -and $PSCmdlet.ShouldProcess($ifAlias, "Remove-NetIPAddress (IPv4)")) {
        $ip | Remove-NetIPAddress -Confirm:$false
        Write-Host "🧹 Host IP temizlendi: $ifAlias" -ForegroundColor Yellow
    }

    # 4) vSwitch sil
    $sw = Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue
    if ($sw -and $PSCmdlet.ShouldProcess($switchName, "Remove-VMSwitch")) {
        Remove-VMSwitch -Name $switchName -Force
        Write-Host "🧱 vSwitch silindi: $switchName" -ForegroundColor Yellow
    }
}

function Setup-LabNat {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([hashtable]$Config)

    if (-not $Config) { $Config = Get-LabNatConfig }

    Ensure-LabNatNetwork -Config $Config
    Add-SwitchAdapterToVMs -Config $Config
    Apply-LabNatGuards -Config $Config
    Show-LabNatStatus -Config $Config
}
