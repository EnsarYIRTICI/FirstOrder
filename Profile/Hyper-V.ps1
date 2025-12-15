function Restart-RunningVMs {
    # Yönetici hakları kontrolü (gerekli, yoksa çıkış)
    if ( -not (Assert-AdminRights-Windows) ) {
        Write-Host "❌ Bu işlemi gerçekleştirmek için yönetici haklarına sahip olmalısınız." -ForegroundColor Red
        return
    }

    Get-VM | Where-Object { $_.State -eq 'Running' } | Restart-VM -Force
}

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

function Switch-VMsToVMSwitch {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$OldSwitch,

        [Parameter(Mandatory=$true)]
        [string]$NewSwitch,

        # İstersen sadece belli VM'lerde çalıştır
        [string[]]$VMName
    )

    # Admin kontrolü (Hyper-V komutları için genelde gerekli)
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "❌ Yönetici olarak çalıştırmalısınız." -ForegroundColor Red
        return
    }

    # Switch var mı kontrol
    $oldExists = Get-VMSwitch -Name $OldSwitch -ErrorAction SilentlyContinue
    $newExists = Get-VMSwitch -Name $NewSwitch -ErrorAction SilentlyContinue

    if (-not $oldExists) { Write-Host "❌ OldSwitch bulunamadı: $OldSwitch" -ForegroundColor Red; return }
    if (-not $newExists) { Write-Host "❌ NewSwitch bulunamadı: $NewSwitch" -ForegroundColor Red; return }

    # VM listesi
    $vms = if ($VMName) { Get-VM -Name $VMName -ErrorAction Stop } else { Get-VM }

    $changes = 0

    foreach ($vm in $vms) {
        $adapters = Get-VMNetworkAdapter -VMName $vm.Name

        foreach ($adapter in $adapters) {
            if ($adapter.SwitchName -eq $OldSwitch) {
                $msg = "VM '$($vm.Name)' adapter '$($adapter.Name)' : $OldSwitch -> $NewSwitch"
                if ($PSCmdlet.ShouldProcess($vm.Name, $msg)) {
                    Write-Host "🔄 $msg"
                    Connect-VMNetworkAdapter -VMName $vm.Name -Name $adapter.Name -SwitchName $NewSwitch
                    $changes++
                }
            } else {
                Write-Host "✔️  VM '$($vm.Name)' adapter '$($adapter.Name)' farklı switch'te ($($adapter.SwitchName)). Atlanıyor."
            }
        }
    }

    Write-Host "`n✅ Tamamlandı. Değiştirilen adapter sayısı: $changes"
}

function Add-VMSwitchAdapterToVMs {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true)]
    [string]$SwitchName,                 # eklenecek switch

    [string[]]$VMName,                   # boşsa tüm VM'ler
    [string[]]$ExcludeVMName = @(),      # hariç tutulacak VM'ler
    [string]$AdapterNamePrefix = "extra" # yeni NIC adı prefix'i
  )

  # Admin kontrolü
  $isAdmin = ([Security.Principal.WindowsPrincipal] `
      [Security.Principal.WindowsIdentity]::GetCurrent()
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  if (-not $isAdmin) {
    Write-Host "❌ Yönetici olarak çalıştırmalısınız." -ForegroundColor Red
    return
  }

  # Switch var mı?
  $sw = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue
  if (-not $sw) { Write-Host "❌ Switch bulunamadı: $SwitchName" -ForegroundColor Red; return }

  # VM listesi
  $vms = if ($VMName) { Get-VM -Name $VMName -ErrorAction Stop } else { Get-VM }
  if ($ExcludeVMName.Count -gt 0) {
    $vms = $vms | Where-Object { $ExcludeVMName -notcontains $_.Name }
  }

  $added = 0
  foreach ($vm in $vms) {
    $adapters = Get-VMNetworkAdapter -VMName $vm.Name

    # Zaten bu switch'e bağlı NIC var mı?
    if ($adapters.SwitchName -contains $SwitchName) {
      Write-Host "✔️  '$($vm.Name)': zaten '$SwitchName' bağlı. Atlanıyor."
      continue
    }

    # Benzersiz NIC adı üret
    $newName = $AdapterNamePrefix
    $i = 1
    while ($adapters.Name -contains $newName) {
      $i++
      $newName = "$AdapterNamePrefix$i"
    }

    $msg = "VM '$($vm.Name)' için yeni adapter ekle: '$newName' -> $SwitchName"
    if ($PSCmdlet.ShouldProcess($vm.Name, $msg)) {
      Write-Host "➕ $msg"
      Add-VMNetworkAdapter -VMName $vm.Name -SwitchName $SwitchName -Name $newName
      $added++
    }
  }

  Write-Host "`n✅ Tamamlandı. Eklenen adapter sayısı: $added"
}

function Get-VMMacAddresses {
    [CmdletBinding()]
    param(
        [Alias("n")]
        [string[]]$VMName,

        [switch]$RunningOnly,

        # Sadece belirtilen switch(ler)e bağlı adapter'lar
        [Alias("s")]
        [string[]]$SwitchName,

        # Format-Table basmasın, obje dönsün (CSV/JSON/pipeline için)
        [switch]$AsObject
    )

    # Yönetici hakları kontrolü (standart setin)
    if ( -not (Assert-AdminRights-Windows) ) {
        Write-Host "❌ Bu işlemi gerçekleştirmek için yönetici haklarına sahip olmalısınız." -ForegroundColor Red
        return
    }

    # Hedef VM seti
    $vms = if ($VMName) {
        Get-VM -Name $VMName -ErrorAction Stop
    } else {
        Get-VM
    }

    if ($RunningOnly) {
        $vms = $vms | Where-Object { $_.State -eq 'Running' }
    }

    $result = foreach ($vm in $vms) {
        $adapters = Get-VMNetworkAdapter -VMName $vm.Name

        if ($SwitchName) {
            $adapters = $adapters | Where-Object { $SwitchName -contains $_.SwitchName }
        }

        $adapters | Select-Object VMName, Name, MacAddress, SwitchName, IPAddresses
    }

    if ($AsObject) {
        return $result
    }

    $result | Format-Table -Auto
}

function New-LabNatNetwork {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true)]
    [Alias("n")]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [Alias("p")]
    [string]$Prefix,          # örn: 10.78.0.0/20

    [Alias("gw")]
    [string]$GatewayIP,       # boşsa network+.1

    [switch]$Force,
    [switch]$PassThru
  )

  if (-not (Assert-AdminRights-Windows)) {
    Write-Host "❌ Bu işlemi gerçekleştirmek için yönetici haklarına sahip olmalısınız." -ForegroundColor Red
    return
  }

  function ConvertTo-UInt32IP([string]$ip) {
    $bytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
    [Array]::Reverse($bytes)
    [BitConverter]::ToUInt32($bytes, 0)
  }
  function ConvertFrom-UInt32IP([uint32]$u) {
    $bytes = [BitConverter]::GetBytes($u)
    [Array]::Reverse($bytes)
    ([System.Net.IPAddress]::new($bytes)).ToString()
  }

  if ($Prefix -notmatch '^(\d{1,3}\.){3}\d{1,3}\/\d{1,2}$') {
    Write-Host "❌ Prefix formatı hatalı. Örn: 10.78.0.0/20" -ForegroundColor Red
    return
  }

  $parts = $Prefix.Split("/")
  $baseIp    = $parts[0]
  $prefixLen = [int]$parts[1]

  if ($prefixLen -lt 1 -or $prefixLen -gt 32) {
    Write-Host "❌ PrefixLength 1-32 arası olmalı." -ForegroundColor Red
    return
  }

  try { [void][System.Net.IPAddress]::Parse($baseIp) }
  catch { Write-Host "❌ Base IP geçersiz: $baseIp" -ForegroundColor Red; return }

  # --- Mask hesabı (PS7 uyumlu, overflow/cast hatası yok) ---
  $ipU    = ConvertTo-UInt32IP $baseIp
  $u32Max = [uint64][uint32]::MaxValue        # 4294967295 (0xFFFFFFFF)
  $shift  = 32 - $prefixLen
  $mask64 = (($u32Max -shl $shift) -band $u32Max)
  $mask   = [uint32]$mask64

  $netU  = [uint32]($ipU -band $mask)
  $netIp = ConvertFrom-UInt32IP $netU

  if (-not $GatewayIP) {
    $GatewayIP = ConvertFrom-UInt32IP ([uint32]($netU + 1))
  }

  $vEthernetName = "vEthernet ($Name)"

  # 1) Internal vSwitch
  $sw = Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue
  if (-not $sw) {
    if ($PSCmdlet.ShouldProcess($Name, "New-VMSwitch (Internal)")) {
      Write-Host "🧩 Internal vSwitch oluşturuluyor: $Name"
      New-VMSwitch -Name $Name -SwitchType Internal | Out-Null
    }
  } else {
    if ($sw.SwitchType -ne 'Internal') {
      Write-Host "❌ '$Name' zaten var ama SwitchType=$($sw.SwitchType). Internal değil." -ForegroundColor Red
      return
    }
    Write-Host "✔️ vSwitch zaten var: $Name (Internal)"
  }

  # 2) vEthernet adaptörüne IP ver
  $if = Get-NetAdapter -Name $vEthernetName -ErrorAction SilentlyContinue
  if (-not $if) {
    Write-Host "❌ Adaptör bulunamadı: $vEthernetName" -ForegroundColor Red
    return
  }

  $existingAll = Get-NetIPAddress -InterfaceIndex $if.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue

  # APIPA'yı (169.254.*) "existing" sayma
  $existingNonApipa = $existingAll | Where-Object { $_.IPAddress -notlike '169.254.*' }

  $hasWanted = $existingAll | Where-Object { $_.IPAddress -eq $GatewayIP -and $_.PrefixLength -eq $prefixLen }

  if (-not $hasWanted) {
    if ($existingNonApipa -and -not $Force) {
      Write-Host "❌ '$vEthernetName' üzerinde IPv4 zaten var ($($existingNonApipa.IPAddress -join ', '))." -ForegroundColor Yellow
      Write-Host "   Uyumlu değilse -Force ile temizleyip yeniden kurabilirsin."
      return
    }

    if ($Force -and $existingAll) {
      if ($PSCmdlet.ShouldProcess($vEthernetName, "Remove mevcut IPv4 adresleri (APIPA dahil)")) {
        Write-Host "🧹 Mevcut IPv4 adresleri temizleniyor: $($existingAll.IPAddress -join ', ')"
        $existingAll | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
      }
    }

    if ($PSCmdlet.ShouldProcess($vEthernetName, "New-NetIPAddress $GatewayIP/$prefixLen")) {
      Write-Host "🌐 IP atanıyor: $GatewayIP/$prefixLen  (Network: $netIp/$prefixLen)"
      New-NetIPAddress -InterfaceIndex $if.ifIndex -IPAddress $GatewayIP -PrefixLength $prefixLen -ErrorAction Stop | Out-Null
    }
  } else {
    Write-Host "✔️ IP zaten doğru: $GatewayIP/$prefixLen"
  }

  # 3) NAT kuralı
  $wantedNatPrefix = "$netIp/$prefixLen"

  $samePrefixNat = Get-NetNat -ErrorAction SilentlyContinue | Where-Object {
    $_.InternalIPInterfaceAddressPrefix -eq $wantedNatPrefix -and $_.Name -ne $Name
  }
  if ($samePrefixNat) {
    Write-Host "❌ Bu prefix zaten başka NAT tarafından kullanılıyor: $($samePrefixNat.Name)" -ForegroundColor Red
    return
  }

  $nat = Get-NetNat -Name $Name -ErrorAction SilentlyContinue
  if ($nat) {
    if ($nat.InternalIPInterfaceAddressPrefix -ne $wantedNatPrefix) {
      if (-not $Force) {
        Write-Host "❌ NAT '$Name' var ama prefix farklı: $($nat.InternalIPInterfaceAddressPrefix)" -ForegroundColor Yellow
        Write-Host "   -Force ile silip yeniden oluşturabilirsin."
        return
      }
      if ($PSCmdlet.ShouldProcess($Name, "Remove-NetNat + New-NetNat ($wantedNatPrefix)")) {
        Write-Host "🧹 NAT yeniden oluşturuluyor: $Name -> $wantedNatPrefix"
        Remove-NetNat -Name $Name -Confirm:$false -ErrorAction SilentlyContinue
        New-NetNat -Name $Name -InternalIPInterfaceAddressPrefix $wantedNatPrefix | Out-Null
      }
    } else {
      Write-Host "✔️ NAT zaten var ve doğru: $Name -> $($nat.InternalIPInterfaceAddressPrefix)"
    }
  } else {
    if ($PSCmdlet.ShouldProcess($Name, "New-NetNat ($wantedNatPrefix)")) {
      Write-Host "🛡️ NAT oluşturuluyor: $Name -> $wantedNatPrefix"
      New-NetNat -Name $Name -InternalIPInterfaceAddressPrefix $wantedNatPrefix | Out-Null
    }
  }

  Write-Host "`n✅ Tamam: Switch='$Name', vEthernetIP='$GatewayIP/$prefixLen', NAT='$wantedNatPrefix'"

  if ($PassThru) {
    [pscustomobject]@{
      Name      = $Name
      GatewayIP = $GatewayIP
      NatPrefix = $wantedNatPrefix
      Switch    = (Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue)
      Adapter   = (Get-NetAdapter -Name $vEthernetName -ErrorAction SilentlyContinue)
      Nat       = (Get-NetNat -Name $Name -ErrorAction SilentlyContinue)
    }
  }
}
