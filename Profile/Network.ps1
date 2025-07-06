function Up-Metric  {
    param(
        [string]$N = "Wi-Fi"
    )

    netsh interface ipv4 set interface $N metric=1
}

function Up-Wifi-Metric {
    Up-Metric -N "Wi-Fi"
}

function Up-Wifi-Ex-Metric {
    Up-Metric -N "vEthernet (wifi-ext-switch)"
}

function Up-Ethernet-Metric {
    Up-Metric -N "Ethernet"
}

function Up-Eth-Ex-Metric {
    Up-Metric -N "vEthernet (eth-ext-switch)"
}