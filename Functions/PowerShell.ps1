function Set-Profile {
    try {
        # Profil dosyasının olup olmadığını kontrol et, yoksa oluştur
        if (!(Test-Path -Path $PROFILE)) {
            New-Item -ItemType File -Path $PROFILE -Force
            Write-Host "Profil dosyası oluşturuldu: $PROFILE"
        }

        # Script dosyalarının olduğu dizini belirle
        $profileDir = Join-Path -Path $scriptDir -ChildPath "Profile"

        # Boş bir dizi oluştur
        $profileScripts = @()

        # Profile dizini varsa, içindeki .ps1 dosyalarını al
        if (Test-Path -Path $profileDir) {
            $ps1Files = Get-ChildItem -Path $profileDir -Filter "*.ps1" -File
            foreach ($file in $ps1Files) {
                # Dosya yolunu profileScripts dizisine ekle
                $profileScripts += $file.FullName
            }
        } else {
            Write-Host "Profile klasörü bulunamadı: $profileDir"
            return
        }

        # Profile dizisindeki script dosyalarını eklemek için kod satırını oluştur
        $i = 1
        $lineToAdd = '$profileScripts = @(' + ($profileScripts | ForEach-Object -Begin { $first = $true } { 
                if ($i -eq $profileScripts.Count) {
                    "`"$($_)`""  # Son öğe, virgül yok
                } else {
                    "`"$($_)`","  # Diğer öğelere virgül ekle
                }
                $i++
            })
        $lineToAdd += ') | ForEach-Object { . $_ }'

        # Profil dosyasına eklemeler
        $alreadyExists = Get-Content $PROFILE | Where-Object { $_ -eq $lineToAdd }

        if (-not $alreadyExists) {
            try {
                Add-Content -Path $PROFILE -Value $lineToAdd
                Write-Host "Script dosyaları profiline eklendi."
            } catch {
                Write-Host "Profil dosyasına ekleme sırasında bir hata oluştu: $_"
            }
        } else {
            Write-Host "Script dosyaları zaten profil dosyasına eklenmiş."
        }
    } catch {
        Write-Host "Profile yükleme sırasında bir hata oluştu: $_"
    }
}
