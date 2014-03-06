default[:openvpn][:key_dir]="/etc/openvpn/easy-rsa/keys"
default[:openvpn][:log_dir]="/var/log/openvpn"
default[:openvpn][:cipher]="BF-CBC"
default[:openvpn][:server][:port]="1194"
default[:openvpn][:server][:proto]="udp"

#cert info
default[:openvpn][:cert][:country]="US"
default[:openvpn][:cert][:province]="CA"
default[:openvpn][:cert][:city]="San Francisco"
default[:openvpn][:cert][:org]="Example Widgets Inc"
default[:openvpn][:cert][:email]="root@example.com"
default[:openvpn][:cert][:cn]="openvpn-server.example.com"
default[:openvpn][:cert][:name]="server"
default[:openvpn][:cert][:ou]="IT"

