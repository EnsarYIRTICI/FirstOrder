function Jwt {
    param(
        [int]$Len = 32
    )

    $bytes = New-Object byte[] $Len
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
    $base64 = [Convert]::ToBase64String($bytes)

    # Base64URL formatına dönüştür (JWT'ler için uygundur)
    $base64Url = $base64 -replace '\+', '-' -replace '/', '_' -replace '=', ''

    Write-Host "JWT Secret Key: $base64Url" -ForegroundColor Green
}
