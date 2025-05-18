function dcu {
    docker-compose up -d --build
}

function dcd {
    docker-compose down
}

function dfwe {
    Get-NetFirewallRule | Where-Object { $_.DisplayName -eq "com.docker.backend" } | Enable-NetFirewallRule

}

function dfwd {
    Get-NetFirewallRule | Where-Object { $_.DisplayName -eq "com.docker.backend" } | Disable-NetFirewallRule
}