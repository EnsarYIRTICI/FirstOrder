## Windows 10/11

```powershell
# PowerShell'i Yönetici olarak açın
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Opsiyonel: Chocolatey yüklemek için (paket yönetimi kolaylığı sağlar)
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Projeye girin
cd .\FirstOrder*

# Script dosyalarını unblock edin
Get-ChildItem -Recurse -Path .\ -Filter *.ps1 | Unblock-File

# Ana scripti çalıştırın
.\Main.ps1
```

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
