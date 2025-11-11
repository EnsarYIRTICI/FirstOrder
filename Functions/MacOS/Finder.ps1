# macOS Finder (Dosya Gezgini) Ayarları

function Show-HiddenFiles {
    <#
    .SYNOPSIS
        Finder'da gizli dosyaları gösterir.
    .DESCRIPTION
        macOS Finder'da gizli dosya ve klasörleri görünür yapar.
    #>
    Write-Host "Gizli dosyalar gösteriliyor..." -ForegroundColor Yellow
    try {
        defaults write com.apple.finder AppleShowAllFiles -bool true
        killall Finder
        Write-Host "✓ Gizli dosyalar artık görünür." -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Hata: Gizli dosyalar gösterilemedi." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Hide-HiddenFiles {
    <#
    .SYNOPSIS
        Finder'da gizli dosyaları gizler.
    .DESCRIPTION
        macOS Finder'da gizli dosya ve klasörleri gizler (varsayılan davranış).
    #>
    Write-Host "Gizli dosyalar gizleniyor..." -ForegroundColor Yellow
    try {
        defaults write com.apple.finder AppleShowAllFiles -bool false
        killall Finder
        Write-Host "✓ Gizli dosyalar artık gizli." -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Hata: Gizli dosyalar gizlenemedi." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Toggle-HiddenFiles {
    <#
    .SYNOPSIS
        Finder'da gizli dosyaları göster/gizle arasında geçiş yapar.
    .DESCRIPTION
        macOS Finder'daki gizli dosyaların görünürlüğünü değiştirir.
    #>
    Write-Host "Gizli dosyaların durumu kontrol ediliyor..." -ForegroundColor Yellow
    try {
        $currentState = defaults read com.apple.finder AppleShowAllFiles 2>$null

        if ($currentState -eq "1" -or $currentState -eq "true") {
            Hide-HiddenFiles
        }
        else {
            Show-HiddenFiles
        }
    }
    catch {
        # Ayar yoksa, varsayılan olarak göster
        Show-HiddenFiles
    }
}
