class SystemSetup {
    SystemSetup() {}

    [void]AssertAdminRights() {
        if ($this.IsWindows) {
            $IsAdmin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'
            if (-not $IsAdmin) {
                $this.WriteLog("Bu script'in Windows'ta yönetici olarak çalıştırılması gerekiyor!")
                Exit 1
            }
        }
        elseif ($this.IsLinux) {
            if ($env:SUDO_USER -eq $null) {
                $this.WriteLog("Bu script'in Linux'ta root olarak çalıştırılması gerekiyor (sudo kullanın)!")
                Exit 1
            }
        }
    }

    [void]InstallChocolatey() {
        if (-not $this.IsWindows) {
            $this.WriteLog("Chocolatey sadece Windows sistemlerde kullanılabilir.")
            return
        }

        $this.WriteLog("Chocolatey kuruluyor...")
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        if ($?) {
            $this.WriteLog("Chocolatey başarıyla kuruldu.")
        } else {
            $this.WriteLog("Chocolatey kurulumu başarısız oldu.")
        }
    }

    [void]InstallWinget() {
        if (-not $this.IsWindows) {
            $this.WriteLog("Winget sadece Windows sistemlerde kullanılabilir.")
            return
        }

        try {
            $progressPreference = 'silentlyContinue'
            $this.WriteLog("WinGet PowerShell modülü PSGallery üzerinden kuruluyor...")
            Install-PackageProvider -Name NuGet -Force | Out-Null
            Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
            $this.WriteLog("WinGet modülü indirildi. Bootstrap işlemi başlatılıyor...")
            Repair-WinGetPackageManager
            $this.WriteLog("WinGet bootstrap tamamlandı. Terminali yeniden başlatmanız gerekebilir.")
        } catch {
            $this.WriteLog("Winget kurulumu sırasında bir hata oluştu: $_")
        }
    }
}