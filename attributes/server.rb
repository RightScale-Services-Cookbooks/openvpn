default[:openvpn][:server][:network_prefix]='192.168.1.0'
default[:openvpn][:server][:subnet_mask] = '255.255.255.0'
default[:openvpn][:server][:c2c] = 'false'
default[:openvpn][:server][:routes] = ""
default[:openvpn][:client][:host_prefix] = 'client'
default[:openvpn][:client][:start_host_number] = '1'
default[:openvpn][:client][:count_start] = 0
default[:openvpn][:client][:count] = 10
default[:openvpn][:server][:max_clients] = 100
default[:openvpn][:client][:domain] = "example.com"
default[:openvpn][:lighttpd][:dir_listing] = "enable"

