# Functions\Core\PowerShell.ps1
function Set-Profile {
    try {
        # Profil dosyasının olup olmadığını kontrol et, yoksa oluştur
        if (!(Test-Path -Path $PROFILE)) {
            New-Item -ItemType File -Path $PROFILE -Force
            Write-Host "Profil dosyası oluşturuldu: $PROFILE"
        }

        # Script dosyalarının olduğu dizini belirle
        $profileDir = Join-Path -Path $scriptDir -ChildPath "Profile"

        # Profile dizini varsa, içindeki .ps1 dosyalarını al
        if (-not (Test-Path -Path $profileDir)) {
            Write-Host "Profile klasörü bulunamadı: $profileDir"
            return
        }

        $profileScripts = Get-ChildItem -Path $profileDir -Filter "*.ps1" -File |
            Select-Object -ExpandProperty FullName

        # profileScripts satırını oluştur
        $i = 1
        $lineToAdd = '$profileScripts = @(' + ($profileScripts | ForEach-Object {
            if ($i -eq $profileScripts.Count) { "`"$_`"" } else { "`"$_`"," }
            $i++
        }) + ') | ForEach-Object { . $_ }'

        # $global:FirstOrderPath satırını oluştur
        $firstOrderLine = "`$global:FirstOrderPath = `"$scriptDir`""

        # Profil içeriğini oku
        $profileContent = Get-Content -Path $PROFILE -ErrorAction SilentlyContinue

        # Eski satırları temizle
        $cleanedContent = $profileContent |
            Where-Object { $_ -notmatch '^\$profileScripts\s*=' } |
            Where-Object { $_ -notmatch '^\$global:FirstOrderPath\s*=' }

        # $global:FirstOrderPath en üste, profileScripts en alta
        $newContent = @($firstOrderLine) + $cleanedContent + $lineToAdd

        # Dosyayı yeniden yaz
        Set-Content -Path $PROFILE -Value $newContent

        Write-Host "Profil güncellendi: $PROFILE"
    } catch {
        Write-Host "Profile yükleme sırasında bir hata oluştu: $_"
    }
}