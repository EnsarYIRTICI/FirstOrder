. "$PSScriptRoot\service\functions.ps1"

Assert-AdminRights

# Sürüm bilgileri
$PSVersion = $PSVersionTable.PSVersion
$osVersion = [System.Environment]::OSVersion.Version
$windowsMajor = $osVersion.Major
$windowsBuild = $osVersion.Build

$isWin10 = $windowsMajor -eq 10 -and $windowsBuild -lt 22000
$isWin11 = $windowsMajor -eq 10 -and $windowsBuild -ge 22000

# Uygulama ve sistem temasını karanlık moda geçirmek ister misin?
if (Confirm-Action "Karanlık moda geçirmek istiyor musun?") {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
        Write-Log "Uygulama ve sistem teması başarıyla karanlık moda geçirildi."
    } catch {
        Write-Host "Bir hata oluştu: $_"
    }
}

# Arama kutusunu yalnızca simge olarak göstermek
if (Confirm-Action "Arama kutusunu simge olarak göstermek ister misiniz?") {
    Write-Log "'Arama kutusu' yalnızca simgeye çevriliyor..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
    Write-Log "Arama kutusu yalnızca simge olarak ayarlandı."
} 


# Görev Görünümü ve Pencere Öğeleri simgeleri kaldırılsın mı?
if (Confirm-Action "'Görev Görünümü' görev çubuğundan gizlensin mi?") {
    try {
        # Görev Görünümü simgesini kaldır
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
    } catch {
        Write-Log "Simgeler kaldırılırken bir hata oluştu: $_"
    }
}

# Masaüstüne "Bu Bilgisayar" ve "Denetim Masası" simgeleri eklensin mi?
if (Confirm-Action "'Bu Bilgisayar' ve 'Denetim Masası' simgeleri masaüstüne eklensin mi?") {
    try {
        Write-Log '"Bu Bilgisayar" ve "Denetim Masası" masaüstüne ekleniyor...'

        # "Bu Bilgisayar" simgesi için
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0

        # "Denetim Masası" simgesi için
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Value 0

        Write-Log 'Simgeler başarıyla masaüstüne eklendi. Değişiklikleri görmek için masaüstünü yenileyin veya oturumu yeniden başlatın.'
    } catch {
        Write-Log "Simgeler eklenirken bir hata oluştu: $_"
    }
}


if($isWin11){
    # Görev çubuğu simgelerini sola hizala (Soru sor)
    if (Confirm-Action "Görev çubuğu simgelerini sola hizalamak istiyor musun? (Sadece Windows 11)") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarAl -Value 0 | Out-Null
        if ($?) { 
            Write-Log "Görev çubuğu simgeleri sola hizalandı." 
            }
    }

    # Görev çubuğundaki "Widgetlar" özelliğini tamamen devre dışı bırak
    if (Confirm-Action "'Pencere Öğeleri' (Widgetlar) özelliğini tamamen devre dışı bırakmak istiyor musun? (Sadece Windows 11)") {
        try {
            # Kayıt defteri yolunu ve değeri ayarla
            $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }

            New-ItemProperty -Path $regPath -Name "AllowNewsAndInterests" -PropertyType DWord -Value 0 -Force | Out-Null

            Write-Log "'Pencere Öğeleri' özelliği tamamen devre dışı bırakıldı."
        } catch {
            Write-Log "Widget özelliği devre dışı bırakılırken bir hata oluştu: $_"
        }
    }

    # Klasik sağ tık menüsünü geri getir (Sadece Windows 11 için - Soru sor)
    if (Confirm-Action "Klasik sağ tık menüsünü geri getirmek istiyor musun? (Sadece Windows 11)") {
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force | Out-Null
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -Force | Out-Null
        New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -PropertyType String -Force | Out-Null
        
        if ($?) { 
            Write-Log "Klasik sağ tık menüsü geri getirildi." 
        }
    }
}


if($isWin10){
    # 'Haberler ve İlgi Alanları' (News and Interests) gizlensin mi?
    if (Confirm-Action "'Haberler ve İlgi Alanları' görev çubuğundan gizlensin mi? (Sadece Windows 10)") {
        try {
            $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }

            New-ItemProperty -Path $regPath -Name "EnableFeeds" -PropertyType DWord -Value 0 -Force | Out-Null
            Write-Log "'Haberler ve İlgi Alanları' görev çubuğundan gizlendi. Değişikliklerin etkili olması için oturumu kapatın veya sistemi yeniden başlatın."
        } catch {
            Write-Log "'Haberler ve İlgi Alanları' devre dışı bırakılırken bir hata oluştu: $_"
        }
    }
}



# Windows Update'i devre dışı bırakılsın mı ?
if (Confirm-Action "Windows Update'i devre dışı bırakmak istiyor musun?") {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Force | Out-Null
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1 -PropertyType DWORD -Force | Out-Null
    if ($?) { Write-Log "Windows Update devre dışı bırakıldı." }
}


# Geliştirici modu açılsın mı?
if (Confirm-Action "Geliştirici Modu etkinleştirilsin mi?") {
    Write-Log "Geliştirici Modu etkinleştiriliyor..."

    try {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
        Write-Log "Geliştirici Modu etkinleştirildi."
    } catch {
        Write-Log "Geliştirici Modu etkinleştirme başarısız oldu: $_"
    }
}

# WSL etkinleştirilsin mi?
if (Confirm-Action "WSL etkinleştirilsin ve kurulsun mu?") {
    Write-Log "WSL etkinleştiriliyor..."
    
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart -ErrorAction Stop | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart -ErrorAction Stop | Out-Null

        Write-Log "WSL özellikleri etkinleştirildi. WSL çekirdeği güncellemesi indiriliyor..."

        wsl --update

        Write-Log "WSL çekirdeği kuruldu. Sisteminizi yeniden başlatmanız gerekebilir."
    } catch {
        Write-Log "WSL etkinleştirme sırasında bir hata oluştu: $_"
    }
} 


# Hyper-V etkinleştirilsin mi?
if (Confirm-Action "Hyper-V etkinleştirilsin mi?") {
    $Edition = (Get-WmiObject -Class Win32_OperatingSystem).OperatingSystemSKU
    # 48 = Professional, 4 = Enterprise, 101 = Education, vs.
    if ($Edition -eq 48 -or $Edition -eq 4 -or $Edition -eq 101) {
        Write-Log "Hyper-V etkinleştiriliyor..."
    
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart -ErrorAction Stop | Out-Null
            Write-Log "Hyper-V etkinleştirildi. Değişikliklerin geçerli olması için sistemi yeniden başlatın."
        } catch {
            Write-Log "Hyper-V etkinleştirilemedi: $_"
        }
    } else {
        Write-Log "Hyper-V bu Windows sürümünde desteklenmiyor."
    }

} 

# 'misafir' adında kullanıcı oluşturulsun mu?
if (Confirm-Action "'misafir' adında bir misafir kullanıcı oluşturmak istiyor musun?") {
    $userExists = Get-LocalUser -Name "misafir" -ErrorAction SilentlyContinue
    if ($null -eq $userExists) {
        New-LocalUser -Name "misafir" -Password (ConvertTo-SecureString "1453" -AsPlainText -Force) -FullName "Misafir" -Description "Misafir kullanıcı hesabı" | Out-Null
        Add-LocalGroupMember -Group "Users" -Member "misafir" | Out-Null
        if ($?) { Write-Log "'misafir' kullanıcısı başarıyla oluşturuldu." }
    } else {
        Write-Log "'misafir' kullanıcısı zaten mevcut."
    }
}
