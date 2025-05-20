function dcu {
    docker-compose up -d --build
}

function dcd {
    docker-compose down
}

function Enable-DockerFWRule {
    Get-NetFirewallRule | Where-Object { $_.DisplayName -eq "com.docker.backend" } | Enable-NetFirewallRule

}

function Disable-DockerFWRule {
    Get-NetFirewallRule | Where-Object { $_.DisplayName -eq "com.docker.backend" } | Disable-NetFirewallRule
}