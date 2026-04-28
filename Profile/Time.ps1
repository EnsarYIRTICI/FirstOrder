# Profile\Time.ps1
function Sync-SystemTime {
    # Admin kontrolü
    if ( -not (Assert-AdminRights-Windows) ) { return }

    Start-Service w32time
    w32tm /resync
}