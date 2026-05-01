# Profile\Docker.ps1

function dcu {
    param (
        [switch]$dev
    )

    if ($dev) {
        docker compose -f .\docker-compose-dev.yml up -d --build
    }
    else {
        docker compose up -d --build
    }
}

function dcd {
    param (
        [switch]$dev
    )

    if ($dev) {
        docker compose -f .\docker-compose-dev.yml down
    }
    else {
        docker compose down
    }
}