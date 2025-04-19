function Ask-YesNo($question) {
    $response = Read-Host "$question (e/h)"
    return $response -match '^[eE]$'
}

function Get-SettingsJSON {
    $json = Get-Content -Path ($scriptDir + "\settings.json") | ConvertFrom-Json
    return $json
}