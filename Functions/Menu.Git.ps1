. "$PSScriptRoot\Git.ps1"

function Git-Settings {

    $gitInstalled = Check-ChocoInstalled

    if (-not $gitInstalled) {
        if (Ask-YesNo "Git yüklü değil. Chocolatey ile yüklemek ister misiniz?") { Install-GitWithChoco }
    }

    if ($gitInstalled) {
        if (Ask-YesNo "Git kullanıcı adı ve e-posta ayarlarını yapalım mı?") { Set-GitGlobalConfig }
    }

}