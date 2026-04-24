function gitfs {
    param(
        [string]$C = "fast"
    )

    git add .
    git commit -m $C
    git push origin master
}

function gitfsc {
    param(
        [string]$M
    )

    if (-not $M) {
        $M = Read-Host "Commit mesajını gir"
    }
    if ([string]::IsNullOrWhiteSpace($M)) {
        $M = "first"
    }

    git add .
    git commit -m $M
    git push origin master
}
