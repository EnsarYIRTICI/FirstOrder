function Sync-SystemTime {
    # Admin kontrolü
    Assert-AdminRights

    Start-Service w32time
    w32tm /resync
}