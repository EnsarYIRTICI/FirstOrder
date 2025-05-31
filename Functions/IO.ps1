function Ask-YesNo($question) {
    $response = Read-Host "$question (e/h)"
    return $response -match '^[eE]$'
}

function Get-SettingsJSON {
    $rawLines = Get-Content -Path ($scriptDir + "\settings.json")

    # Sadece // ile başlayan veya satır içinde // olan kısımları temizle
    $cleanLines = $rawLines | ForEach-Object {
        # Eğer satır tamamen // ile başlıyorsa, boş dön
        if ($_ -match '^\s*//') { "" }
        else {
            # Satır içinde // varsa, ilk // öncesini al
            if ($_ -match '//') {
                ($_ -split '//')[0]
            }
            else { $_ }
        }
    }

    # Temizlenen satırları tekrar birleştirip string yap
    $jsonText = $cleanLines -join "`n"

    # JSON olarak parse et
    $json = $jsonText | ConvertFrom-Json
    return $json
}
