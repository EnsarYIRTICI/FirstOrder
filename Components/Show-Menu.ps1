function Show-Menu {
    [CmdletBinding()]
    param(
        # @{ Label = "..."; Action = { ... } } dizisi
        [Parameter(Mandatory)]
        [array] $MenuItems,

        # Üst başlık/metin
        [string] $Title = "Ana Menü",
        [string] $Prompt = "Seçiminiz",
        [string] $ExitKey = "Q",

        # Görsel/akış seçenekleri
        [switch] $ClearOnEachLoop,
        [switch] $PauseAfterAction
    )

    # Basit doğrulama
    foreach ($item in $MenuItems) {
        if (-not ($item.ContainsKey('Label') -and $item.ContainsKey('Action'))) {
            throw "Her menü öğesi 'Label' (string) ve 'Action' (ScriptBlock) anahtarlarını içermelidir."
        }
        if (-not ($item.Action -is [ScriptBlock])) {
            throw "'Action' bir ScriptBlock olmalıdır. Label: $($item.Label)"
        }
    }

    do {
        if ($ClearOnEachLoop) { Clear-Host }

        Write-Host ""
        Write-Host "=== $Title ===" -ForegroundColor Cyan
        Write-Host "Ne yapmak istiyorsunuz?" -ForegroundColor Cyan

        for ($i = 0; $i -lt $MenuItems.Count; $i++) {
            Write-Host ("{0}. {1}" -f ($i + 1), $MenuItems[$i].Label)
        }
        Write-Host ("{0}. Çıkış" -f $ExitKey.ToUpper())

        $choice = Read-Host ("$Prompt (1-{0}, {1})" -f $MenuItems.Count, $ExitKey.ToUpper())

        switch ($choice.ToUpper()) {
            $ExitKey {
                Write-Host "Çıkılıyor..." -ForegroundColor Yellow
            }
            default {
                if ($choice -as [int] -and
                    [int]$choice -ge 1 -and
                    [int]$choice -le $MenuItems.Count) {

                    $action = $MenuItems[[int]$choice - 1].Action
                    try {
                        & $action
                    } catch {
                        Write-Host "Bir hata oluştu: $_" -ForegroundColor Red
                    }

                    # if ($PauseAfterAction -and ($choice.ToUpper() -ne $ExitKey.ToUpper())) {
                    #     Write-Host "`nDevam etmek için bir tuşa basın..." -ForegroundColor DarkGray
                    #     [void][System.Console]::ReadKey($true)
                    # }
                } else {
                    Write-Host "Geçersiz seçim yapıldı, lütfen tekrar deneyin." -ForegroundColor Red
                }
            }
        }
    } while ($choice.ToUpper() -ne $ExitKey.ToUpper())
}
