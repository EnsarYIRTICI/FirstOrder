. "$PSScriptRoot\service\functions.ps1"

# Sürüm bilgileri

$PSVersion = $PSVersionTable.PSVersion
$osVersion = [System.Environment]::OSVersion.Version

$setup = [SystemSetup]::new()

$setup.AssertAdminRights()

if ($IsWindows) 
{
    # Sürüm bilgileri
    $PSVersion = $PSVersionTable.PSVersion
    $osVersion = [System.Environment]::OSVersion.Version
    
    $windowsMajor = $osVersion.Major
    $windowsBuild = $osVersion.Build

    $isWin10 = $windowsMajor -eq 10 -and $windowsBuild -lt 22000
    $isWin11 = $windowsMajor -eq 10 -and $windowsBuild -ge 22000

    # Uygulama ve sistem temasını karanlık moda geçirmek ister misin?
    $response = Read-Host "Karanlık moda geçirmek istiyor musun? (e/h)"
    if ($response -match '^[eE]$') {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
            Write-Host "Uygulama ve sistem teması başarıyla karanlık moda geçirildi."
        } catch {
            Write-Host "Bir hata oluştu: $_"
        }
    }

    # Arama kutusunu yalnızca simge olarak göstermek
    $response = Read-Host "Arama kutusunu simge olarak göstermek ister misiniz? (e/h)"
    if ($response -match '^[eE]$') {
        Write-Host "'Arama kutusu' yalnızca simgeye çevriliyor..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
        Write-Host "Arama kutusu yalnızca simge olarak ayarlandı."
    } 

    # Görev Görünümü ve Pencere Öğeleri simgeleri kaldırılsın mı?
    $response = Read-Host "'Görev Görünümü' görev çubuğundan gizlensin mi? (e/h)"
    if ($response -match '^[eE]$') {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
        } catch {
            Write-Host "Simgeler kaldırılırken bir hata oluştu: $_"
        }
    }

    # Masaüstüne "Bu Bilgisayar" ve "Denetim Masası" simgeleri eklensin mi?
    $response = Read-Host "'Bu Bilgisayar' ve 'Denetim Masası' simgeleri masaüstüne eklensin mi? (e/h)"
    if ($response -match '^[eE]$') {
        try {
            Write-Host '"Bu Bilgisayar" ve "Denetim Masası" masaüstüne ekleniyor...'

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Value 0

            Write-Host 'Simgeler başarıyla masaüstüne eklendi. Değişiklikleri görmek için masaüstünü yenileyin veya oturumu yeniden başlatın.'
        } catch {
            Write-Host "Simgeler eklenirken bir hata oluştu: $_"
        }
    }

    if ($isWin11){
        $response = Read-Host "Görev çubuğu simgelerini sola hizalamak istiyor musun? (Sadece Windows 11) (e/h)"
        if ($response -match '^[eE]$') {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarAl -Value 0 | Out-Null
            if ($?) { 
                Write-Host "Görev çubuğu simgeleri sola hizalandı." 
            }
        }

        $response = Read-Host "'Pencere Öğeleri' (Widgetlar) özelliğini tamamen devre dışı bırakmak istiyor musun? (Sadece Windows 11) (e/h)"
        if ($response -match '^[eE]$') {
            try {
                $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
                if (-not (Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                }

                New-ItemProperty -Path $regPath -Name "AllowNewsAndInterests" -PropertyType DWord -Value 0 -Force | Out-Null

                Write-Host "'Pencere Öğeleri' özelliği tamamen devre dışı bırakıldı."
            } catch {
                Write-Host "Widget özelliği devre dışı bırakılırken bir hata oluştu: $_"
            }
        }

        $response = Read-Host "Klasik sağ tık menüsünü geri getirmek istiyor musun? (Sadece Windows 11) (e/h)"
        if ($response -match '^[eE]$') {
            New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force | Out-Null
            New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -Force | Out-Null
            New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -PropertyType String -Force | Out-Null
            
            if ($?) { 
                Write-Host "Klasik sağ tık menüsü geri getirildi." 
            }
        }
    }

    if ($isWin10){
        $response = Read-Host "'Haberler ve İlgi Alanları' görev çubuğundan gizlensin mi? (Sadece Windows 10) (e/h)"
        if ($response -match '^[eE]$') {
            try {
                $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
                if (-not (Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                }

                New-ItemProperty -Path $regPath -Name "EnableFeeds" -PropertyType DWord -Value 0 -Force | Out-Null
                Write-Host "'Haberler ve İlgi Alanları' görev çubuğundan gizlendi. Değişikliklerin etkili olması için oturumu kapatın veya sistemi yeniden başlatın."
            } catch {
                Write-Host "'Haberler ve İlgi Alanları' devre dışı bırakılırken bir hata oluştu: $_"
            }
        }
    }

    $response = Read-Host "Windows Update'i devre dışı bırakmak istiyor musun? (e/h)"
    if ($response -match '^[eE]$') {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Force | Out-Null
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1 -PropertyType DWORD -Force | Out-Null
        if ($?) { Write-Host "Windows Update devre dışı bırakıldı." }
    }

    $response = Read-Host "Geliştirici Modu etkinleştirilsin mi? (e/h)"
    if ($response -match '^[eE]$') {
        Write-Host "Geliştirici Modu etkinleştiriliyor..."
        try {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force | Out-Null
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
            Write-Host "Geliştirici Modu etkinleştirildi."
        } catch {
            Write-Host "Geliştirici Modu etkinleştirme başarısız oldu: $_"
        }
    }

    $response = Read-Host "WSL etkinleştirilsin ve kurulsun mu? (e/h)"
    if ($response -match '^[eE]$') {
        Write-Host "WSL etkinleştiriliyor..."
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart -ErrorAction Stop | Out-Null
            Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart -ErrorAction Stop | Out-Null
            Write-Host "WSL özellikleri etkinleştirildi. WSL çekirdeği güncellemesi indiriliyor..."
            wsl --update
            Write-Host "WSL çekirdeği kuruldu. Sisteminizi yeniden başlatmanız gerekebilir."
        } catch {
            Write-Host "WSL etkinleştirme sırasında bir hata oluştu: $_"
        }
    }

    $response = Read-Host "Hyper-V etkinleştirilsin mi? (e/h)"
    if ($response -match '^[eE]$') {
        $Edition = (Get-WmiObject -Class Win32_OperatingSystem).OperatingSystemSKU
        if ($Edition -eq 48 -or $Edition -eq 4 -or $Edition -eq 101) {
            Write-Host "Hyper-V etkinleştiriliyor..."
            try {
                Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart -ErrorAction Stop | Out-Null
                Write-Host "Hyper-V etkinleştirildi. Değişikliklerin geçerli olması için sistemi yeniden başlatın."
            } catch {
                Write-Host "Hyper-V etkinleştirilemedi: $_"
            }
        } else {
            Write-Host "Hyper-V bu Windows sürümünde desteklenmiyor."
        }
    }

    $response = Read-Host "'misafir' adında bir misafir kullanıcı oluşturmak istiyor musun? (e/h)"
    if ($response -match '^[eE]$') {
        $userExists = Get-LocalUser -Name "misafir" -ErrorAction SilentlyContinue
        if ($null -eq $userExists) {
            New-LocalUser -Name "misafir" -Password (ConvertTo-SecureString "1453" -AsPlainText -Force) -FullName "Misafir" -Description "Misafir kullanıcı hesabı" | Out-Null
            Add-LocalGroupMember -Group "Users" -Member "misafir" | Out-Null
            if ($?) { Write-Host "'misafir' kullanıcısı başarıyla oluşturuldu." }
        } else {
            Write-Host "'misafir' kullanıcısı zaten mevcut."
        }
    }
}
