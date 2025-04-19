function Jwt {
    param(
        [int]$Len = 32
    )

    $bytes = New-Object byte[] $Len
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
    $secret = [Convert]::ToBase64String($bytes)
    Write-Host "JWT Secret Key: $secret" -ForegroundColor Green
}
