## Windows 10/11

```powershell
# PowerShell'i Yönetici olarak açın
Start powershell -Verb runAs

# Geçerli kullanıcı için PowerShell komutlarının çalıştırılmasına izin verir (uzaktan imzalı olanlar)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Projeye girin
cd .\FirstOrder*

# Script dosyalarını unblock edin
Get-ChildItem -Recurse -Path .\ -Filter *.ps1 | Unblock-File

# Ana scripti çalıştırın
.\Main.ps1
```

#### Opsiyonel
```powershell
# PowerShell'i Yönetici olarak açın
Start powershell -Verb runAs

# Opsiyonel: Winget yüklemek için (Microsoft Store paket yöneticisi)
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
Add-AppxPackage .\winget.msixbundle

# Opsiyonel: Chocolatey yüklemek için (paket yönetimi kolaylığı sağlar)
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Chocolatey ile pwsh ve git kurulumu
choco install pwsh git -y

# Depoyu klonla
git clone https://github.com/EnsarYIRTICI/FirstOrder.git
```

## MacOS

### 1. Homebrew Kurulumu
Homebrew, MacOS için popüler bir paket yöneticisidir. Eğer yüklü değilse, önce Homebrew'i kurmalısınız:

```bash
# Terminal'i açın ve aşağıdaki komutu çalıştırın
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Kurulum tamamlandıktan sonra, Homebrew'in PATH'e eklendiğinden emin olun
# M1/M2/M3 Mac için (Apple Silicon):
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac için:
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### 2. PowerShell Kurulumu ve Script Çalıştırma

```bash
# Homebrew ile PowerShell kurulumu
brew install --cask powershell

# Git kurulumu (eğer yüklü değilse)
brew install git

# Depoyu klonla
git clone https://github.com/EnsarYIRTICI/FirstOrder.git

# Projeye girin
cd FirstOrder

# PowerShell'i başlatın ve scripti çalıştırın
pwsh ./Main.ps1
```

### Alternatif: Manuel PowerShell Kurulumu
Eğer Homebrew kullanmak istemiyorsanız, PowerShell'i doğrudan Microsoft'tan indirebilirsiniz:
1. [PowerShell GitHub Releases](https://github.com/PowerShell/PowerShell/releases) sayfasına gidin
2. En son sürümden `.pkg` dosyasını indirin (örn: `powershell-7.x.x-osx-x64.pkg`)
3. İndirilen dosyayı çift tıklayarak kurulumu tamamlayın

## Linux/Debian

```bash
# Güncelleme ve gerekli paketler
sudo apt update && sudo apt install -y wget apt-transport-https software-properties-common

# Microsoft repo ekleme
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

# PowerShell yükleme
sudo apt update && sudo apt install -y powershell

# Projeye girip scripti çalıştırma
cd ./FirstOrder*
sudo pwsh ./Main.ps1
```
