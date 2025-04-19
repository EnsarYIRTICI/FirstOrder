. "$PSScriptRoot\IO.ps1"

function Set-GitGlobalConfig {
    $settings = Get-SettingsJSON
    
    $gitUserName = $settings.git_user.name
    $gitUserEmail = $settings.git_user.email

    # Git kullanıcı bilgilerini ayarlıyoruz
    git config --global user.name $gitUserName
    git config --global user.email $gitUserEmail

    Write-Host "Git global config updated with user: $gitUserName and email: $gitUserEmail"
}

function Check-GitInstalled {
    $global:gitInstalled = Get-Command git -ErrorAction SilentlyContinue
    return $global:gitInstalled -ne $null
}