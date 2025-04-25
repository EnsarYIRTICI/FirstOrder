. "$PSScriptRoot\Git.ps1"

function Git-Settings {
    if(Check-GitInstalled){
        if (Ask-YesNo "Git kullanıcı adı ve e-posta ayarlarını yapalım mı?") { Set-GitGlobalConfig }
    }
}