function Git-FirstPush {
    git add .
    git commit -m "first"
    git push origin master
}


function Git-FastPush {
    param(
        [string]$Message = "fast"
    )

    git add .
    git commit -m $Message
    git push origin master
}

