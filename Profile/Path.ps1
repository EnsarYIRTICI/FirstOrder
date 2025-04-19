function Path {
    $paths = [Environment]::GetEnvironmentVariable("PATH", "User") -split ";"

    if (-not $paths) {
        Write-Output "PATH değişkeni boş!"
        return
    }

    for ($i = 0; $i -lt $paths.Length; $i++) {
        Write-Output "$i): $($paths[$i])"
    }
}

function Path-Add {
    param (
        [string]$Path
    )

    if (-not $PSBoundParameters.ContainsKey('Path')) {
        $Path = Read-Host "Lütfen eklemek istediğiniz dizini girin"
    }

    if (-not (Test-Path $Path)) {
        Write-Output "Hata: '$Path' geçerli bir dizin değil!"
        return
    }

    $paths = [Environment]::GetEnvironmentVariable("PATH", "User") -split ";"

    if ($paths -contains $Path) {
        Write-Output "Bu dizin zaten PATH değişkeninde mevcut: $Path"
        return
    }

    $updatedPath = ($paths + $Path) -join ";"

    [Environment]::SetEnvironmentVariable("PATH", $updatedPath, "User")

    $env:PATH = $updatedPath

    Write-Output "Dizin başarıyla PATH değişkenine eklendi: $Path"
}

function Path-Remove {
    param (
        [int]$Index
    )

    if (-not $PSBoundParameters.ContainsKey('Index')) {
        do {
            $input = Read-Host "Lütfen bir indeks girin"
            if ($input -match '^\d+$') {
                $Index = [int]$input
                $validIndex = $true
            } else {
                Write-Output "Hata: Lütfen geçerli bir tam sayı girin!"
                $validIndex = $false
            }
        } while (-not $validIndex)
    }

    $paths = [Environment]::GetEnvironmentVariable("PATH", "User") -split ";"

    if ($Index -lt 0 -or $Index -ge $paths.Length) {
        Write-Output "Geçersiz indeks: $Index. Lütfen doğru bir indeks girin."
        return
    }

    Write-Output "Silinecek giriş: $($paths[$Index])"

    if ($Index -eq 0) {
        $paths = $paths[1..($paths.Length-1)]
    } elseif ($Index -eq $paths.Length - 1) {
        $paths = $paths[0..($paths.Length - 2)]
    } else {
        $paths = $paths[0..($Index-1)] + $paths[($Index+1)..($paths.Length-1)]
    }
    
    $paths = $paths | Where-Object { $_ -ne "" }

    if ($paths.Count -eq 0) {
        $updatedPath = ""
    }  else {
        $updatedPath = ($paths -join ";")
    }

    [Environment]::SetEnvironmentVariable("PATH", $updatedPath, "User")

    $env:PATH = $updatedPath

    Write-Output "İndeks $Index kaldırıldı. Güncellenmiş PATH kaydedildi."
}


