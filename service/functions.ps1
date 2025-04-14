# Bu fonksiyon, script'in yönetici yetkileriyle çalışıp çalışmadığını kontrol eder.
function Assert-AdminRights {
    $IsAdmin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'

    if (-not $IsAdmin) {
        Write-Log "Bu script'in yönetici olarak çalıştırılması gerekiyor!"
        Exit 1
    }
}

# Terminal çıktısı için log fonksiyonu
function Write-Log {
    param (
        [string]$message
    )
    # Terminale log yazdır
    Write-Host "[LOG] $message"
}

# Kullanıcıdan onay almak için fonksiyon
function Confirm-Action {
    param (
        [string]$question
    )
    do {
        $response = Read-Host "$question (e/h)"
    } while ($response -notmatch '^[eh]$')

    return $response -eq 'e'
}

# Chocolatey kurulum fonksiyonu
function Install-Chocolatey {
    Write-Log "Chocolatey kuruluyor..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    if ($?) {
        Write-Log "Chocolatey başarıyla kuruldu."
    } else {
        Write-Log "Chocolatey kurulumu başarısız oldu."
    }
}

# Winget kurulum fonksiyonu
function Install-Winget {
    try {
        $progressPreference = 'silentlyContinue'
        Write-Log "WinGet PowerShell modülü PSGallery üzerinden kuruluyor..."
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
        Write-Log "WinGet modülü indirildi. Bootstrap işlemi başlatılıyor..."
        Repair-WinGetPackageManager
        Write-Log "WinGet bootstrap tamamlandı. Terminali yeniden başlatmanız gerekebilir."
    } catch {
        Write-Log "Winget kurulumu sırasında bir hata oluştu: $_"
    }
}