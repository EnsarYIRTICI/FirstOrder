function Reload-Profile {
    $profileDir = Join-Path (Split-Path $PROFILE -Parent) "..\..\repo\powershell\FirstOrder\Profile"
    # ya da daha temizi:
    $profileDir = Join-Path $HOME "repo\powershell\FirstOrder\Profile"
    Get-ChildItem -Path $profileDir -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Write-Host "Profil yeniden yüklendi." -ForegroundColor Green
}