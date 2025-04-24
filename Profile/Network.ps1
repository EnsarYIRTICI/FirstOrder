function Wifi-Metric {
    netsh interface ipv4 set interface "Wi-Fi" metric=1
}

function Ex-Metric {
    netsh interface ipv4 set interface "vEthernet (external-switch)" metric=1
}