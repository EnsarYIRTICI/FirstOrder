. "$PSScriptRoot\IO.ps1"

function Check-GitInstalled {
    try {
        git --version
        Write-Host "Git is installed."
    } catch {
        Write-Host "Git is not installed."
    }
}

function Set-GitGlobalConfig {
    $settings = Get-SettingsJSON
    
    $gitUserName = $settings.git_user.name
    $gitUserEmail = $settings.git_user.email

    # Git kullanıcı bilgilerini ayarlıyoruz
    git config --global user.name $gitUserName
    git config --global user.email $gitUserEmail

    Write-Host "Git global config updated with user: $gitUserName and email: $gitUserEmail"
}