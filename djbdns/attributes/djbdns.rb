default.djbdns[:tinydns_ipaddress] = "127.0.0.1"
default.djbdns[:tinydns_internal_ipaddress] = "127.0.0.1"
default.djbdns[:axfrdns_ipaddress] = "127.0.0.1"
default.djbdns[:public_dnscache_ipaddress] = node[:ipaddress]
# Default allowed networks is the current network class B
default.djbdns[:public_dnscache_allowed_networks] = [node[:ipaddress].split(".")[0,2].join(".")]
# Reverse DNS (PTR) networks
default.djbdns[:ptr_networks] = ['10.10', '172.16']