name             'openvpn'
maintainer       'RightScale Inc'
maintainer_email 'premium@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures openvpn'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "rightscale"
depends "sys_firewall"

recipe "openvpn::client-cert-create", "creates client certs"
recipe "openvpn::client", "installs client software, and downloads client certs"
recipe "openvpn::default", "install openvpn base software, needed for both client and server"
recipe "openvpn::lighttpd", "installs lighthttpd for serving certs"
recipe "openvpn::server", "install openvpn server"

#openvpn default
attribute "openvpn/client/host_prefix",
  :display_name => "OpenVPN Client Host Prefix",
  :description => "OpenVPN Client Certificate Host Prefix",
  :default => 'client', 
  :required => "optional"

attribute "openvpn/client/start_host_number",
  :display_name => "OpenVPN Client First Host Number",
  :description => "OpenVPN Client First Host Number",
  :default => "1", 
  :required => "optional"

attribute "openvpn/client/count",
  :display_name => "OpenVPN Client Count",
  :description => "Number of OpenVPN Client Certs to Create",
  :default => "20",
  :required => "optional"
  
attribute "openvpn/client/domain",
  :display_name => "OpenVPN Client Domain",
  :description => "OpenVPN Client Domain",
  :default => "example.com",
  :required => "optional"

#openvpn server
attribute "openvpn/server/network_prefix",
  :display_name => "OpenVPN Network Prefix",
  :description => "OpenVPN Network Prefix",
  :default => '192.168.1.0',
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/server/subnet_mask",
  :display_name => "OpenVPN Subnet Mask",
  :description => "OpenVPN Subnet Mask",
  :default =>  '255.255.255.0',
  :required => "optional",
  :recipes => [ "openvpn::server" ]

#openvpn client
attribute "openvpn/server",
  :display_name => "OpenVPN Server",
  :description => "OpenVPN Server",
  :required => "required",
  :recipes => [ "openvpn::client" ]

attribute "openvpn/client/key_base_url",
  :display_name => "OpenVPN Client Package Base URL",
  :description => "OpenVPN Client Package Base URL",
  :required => "required",
  :recipes => [ "openvpn::client" ]

attribute "openvpn/client/host_number",
  :display_name => "OpenVPN Client Host Number",
  :description => "OpenVPN Client Host Number",
  :required => "required",
  :recipes => [ "openvpn::client" ]
