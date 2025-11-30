function Set-MouseSpeed {
    [CmdletBinding()]
    param(
        # 1 = en yavaş, 20 = en hızlı
        [Parameter(Mandatory = $true)]
        [ValidateRange(1,20)]
        [int]$Speed,

        # İstersen Windows'un "işaretçi hassasiyetini arttır" özelliğini de kapat
        [switch]$DisablePointerPrecision
    )

    $mouseKey = 'HKCU:\Control Panel\Mouse'

    # Registry'de imleç hızını ayarla
    Set-ItemProperty -Path $mouseKey -Name MouseSensitivity -Value $Speed

    if ($DisablePointerPrecision) {
        Set-ItemProperty -Path $mouseKey -Name MouseSpeed      -Value 0
        Set-ItemProperty -Path $mouseKey -Name MouseThreshold1 -Value 0
        Set-ItemProperty -Path $mouseKey -Name MouseThreshold2 -Value 0
    }

    # WinAPI tipi daha önce eklenmediyse ekle
    if (-not ('MouseNative' -as [type])) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class MouseNative {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(
        int uiAction,
        int uiParam,
        ref int pvParam,
        int fWinIni
    );
}
"@
    }

    # Sabitler
    $SPI_SETMOUSESPEED  = 0x0071
    $SPIF_UPDATEINIFILE = 0x01
    $SPIF_SENDCHANGE    = 0x02

    # Ayarı anında uygula
    [MouseNative]::SystemParametersInfo(
        $SPI_SETMOUSESPEED,
        0,
        [ref]$Speed,
        $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE
    ) | Out-Null
}
