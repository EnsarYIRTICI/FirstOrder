function Git-FastPush {
    param(
        [string]$Message = "update"
    )

    git add .
    git commit -m $Message
    git push origin master
}

