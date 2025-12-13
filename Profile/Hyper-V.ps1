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

