# Profile\Utils.ps1
function Reload-Profile {
    Get-ChildItem -Path (Join-Path $global:FirstOrderPath "Profile") -Filter "*.ps1" |
        ForEach-Object { . $_.FullName }
    Write-Host "Profil yeniden yüklendi." -ForegroundColor Green
}