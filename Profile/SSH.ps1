function pubkey {
    $keyPath = "$HOME\.ssh\id_ed25519.pub"

    if (Test-Path $keyPath) {
        $key = Get-Content $keyPath -Raw
        $key | Set-Clipboard
        Write-Host "Public key panoya kopyalandı ✔️"
        $key
    } else {
        Write-Error "Public key bulunamadı: $keyPath"
    }
}
