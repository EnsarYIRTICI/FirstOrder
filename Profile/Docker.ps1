# Profile\Docker.ps1
function dcu {
    docker-compose up -d --build
}

function dcd {
    docker-compose down
}