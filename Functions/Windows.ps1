function Detect-WindowsVersion {
    $version = [System.Environment]::OSVersion.Version
    $global:windowsVersion = 0
    $global:isWin10 = $false
    $global:isWin11 = $false

    if ($version.Major -eq 10) {
        if ($version.Build -lt 22000) {
            $global:windowsVersion = 10
            $global:isWin10 = $true
        } elseif ($version.Build -ge 22000) {
            $global:windowsVersion = 11
            $global:isWin11 = $true
        }
    }
}