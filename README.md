## Windows 10/11

#### cd FirstOrder
#### Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
#### Get-ChildItem -Recurse -Path .\ -Filter *.ps1 | Unblock-File
#### .\Main.ps1

## Linux/Debian

#### sudo apt update && sudo apt install -y wget apt-transport-https software-properties-common

#### wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
#### sudo dpkg -i packages-microsoft-prod.deb

#### sudo apt update && sudo apt install -y powershell
#### sudo pwsh
#### cd FirstOrder
#### .\Main.ps1

