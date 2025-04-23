function Git-FastPush {
    param(
        [string]$Message = "improvement"
    )

    git add .
    git commit -m $Message
    git push origin master
}

