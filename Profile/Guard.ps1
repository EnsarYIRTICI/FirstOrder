function Assert-AdminRights-Windows {
    $IsAdmin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'
    if (-not $IsAdmin) {
        Write-Host "Bu script'in Windows'ta yönetici olarak çalıştırılması gerekiyor!" -ForegroundColor Red
        return $false
    }
    return $true
}   