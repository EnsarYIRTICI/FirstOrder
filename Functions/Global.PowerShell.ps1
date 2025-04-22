function Set-Profile {
    try {
        if (!(Test-Path -Path $PROFILE)) {
            New-Item -ItemType File -Path $PROFILE -Force
        }

        $profileDir = Join-Path -Path $scriptDir -ChildPath "Profile"

        if (Test-Path -Path $profileDir) {
            $ps1Files = Get-ChildItem -Path $profileDir -Filter "*.ps1" -File
            foreach ($file in $ps1Files) {
                $lineToAdd = ". `"$($file.FullName)`""
                $alreadyExists = Get-Content $PROFILE | Where-Object { $_ -eq $lineToAdd }

                if (-not $alreadyExists) {
                    Add-Content -Path $PROFILE -Value $lineToAdd
                    Write-Host "`"$($file.Name)`" profiline eklendi."
                } else {
                    Write-Host "`"$($file.Name)`" zaten profil dosyasında mevcut."
                }
            }
        } else {
            Write-Host "Profile klasörü bulunamadı: $profileDir"
        }
    } catch {
        Write-Host "Profile yükleme sırasında bir hata oluştu: $_"
    }
}