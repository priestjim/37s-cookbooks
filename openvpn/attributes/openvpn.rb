default.openvpn[:local]   = node[:ipaddress]
default.openvpn[:proto]   = "udp"
default.openvpn[:type]    = "server"
default.openvpn[:subnet]  = "10.8.0.0"
default.openvpn[:netmask] = "255.255.0.0"
