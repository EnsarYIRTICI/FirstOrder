function Ask-YesNo($question) {
    $response = Read-Host "$question (e/h)"
    return $response -match '^[eE]$'
}
