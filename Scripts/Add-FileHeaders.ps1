# Scripts/Add-FileHeaders.ps1

[CmdletBinding()]
param(
    [string]$BaseDir,
    [switch]$WhatIf
)

if (-not $BaseDir) {
    $BaseDir = Split-Path $PSScriptRoot -Parent
}

$BaseDir = (Resolve-Path $BaseDir).Path

Write-Host "== Dosya Başlıkları Ekleniyor ==" -ForegroundColor Cyan
Write-Host "Kök dizin: $BaseDir" -ForegroundColor DarkGray

$files = Get-ChildItem -Path $BaseDir -Recurse -Filter "*.ps1" -File |
    Where-Object { $_.FullName -notmatch '\\\.git\\' }

$updated = 0
$skipped = 0

foreach ($file in $files) {
    # Kök dizine göreceli yol — örn: Profile/App.ps1
    $relativePath = $file.FullName.Substring($BaseDir.Length).TrimStart('\', '/')
    $expectedComment = "# $relativePath"

    $content = Get-Content -Path $file.FullName -Raw

    if ($null -eq $content) { $content = "" }

    # Zaten doğru yorum satırı varsa geç
    if ($content.StartsWith($expectedComment)) {
        $skipped++
        continue
    }

    # Eski konum yorumu varsa kaldır (# ile başlayan ilk satır "# " + yol içeriyorsa)
    $lines = $content -split "`r?`n"
    if ($lines.Count -gt 0 -and $lines[0] -match '^# .+[/\\].+\.ps1$') {
        $lines = $lines[1..$lines.GetUpperBound(0)]
        $content = $lines -join "`n"
    }

    $newContent = "$expectedComment`n$content"

    if ($WhatIf) {
        Write-Host "[WhatIf] Güncellenecek: $relativePath" -ForegroundColor Yellow
    }
    else {
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
        Write-Host "Güncellendi: $relativePath" -ForegroundColor Green
    }

    $updated++
}

Write-Host ""
Write-Host "Tamamlandı — Güncellenen: $updated | Atlanan: $skipped" -ForegroundColor Cyan