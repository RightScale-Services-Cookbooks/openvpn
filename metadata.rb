name             'openvpn'
maintainer       'RightScale Inc'
maintainer_email 'premium@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures openvpn'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.0'

depends "rightscale"
depends "sys_firewall"

recipe "openvpn::create_numbered_clinet_certs", "Creates 'openvpn/client/count' numbered client certs starting from 'openvpn/client/count_start'"
recipe "openvpn::create_named_clinet_certs", "Creates named client certs"
recipe "openvpn::client", "Installs client software, and downloads client certs"
recipe "openvpn::default", "Install openvpn base software, needed for both client and server"
recipe "openvpn::lighttpd", "Installs lighthttpd for serving certs"
recipe "openvpn::server", "Install openvpn server"

#openvpn default
attribute "openvpn/client/host_prefix",
  :display_name => "OpenVPN Client Host Prefix",
  :description => "OpenVPN Client Certificate Host Prefix",
  :default => 'client', 
  :required => "optional",
  :recipes => [ "openvpn::create_named_clinet_certs", "create_numbered_clinet_certs" ]

attribute "openvpn/client/count_start",
  :display_name => "OpenVPN Client First Host Number",
  :description => "OpenVPN Client First Host Number",
  :default => "1", 
  :required => "optional",
  :recipes => [ "create_numbered_clinet_certs" ]

attribute "openvpn/client/count",
  :display_name => "OpenVPN Client Count",
  :description => "Number of OpenVPN Client Certs to Create",
  :default => "20",
  :required => "optional",
  :recipes => [ "create_numbered_clinet_certs" ]
  
attribute "openvpn/client/names",
  :display_name => "OpenVPN Client Name(s)",
  :description => "One or a comma-separated list of client names to create openvpn certs for. Ex: john_doe,jane_doe",
  :default => "client",
  :required => "optional",
  :recipes => [ "openvpn::create_named_clinet_certs" ]
  
attribute "openvpn/client/domain",
  :display_name => "OpenVPN Client Domain",
  :description => "OpenVPN Client Domain",
  :default => "example.com",
  :required => "optional",
  :recipes => [ "openvpn::client", "openvpn::create_named_clinet_certs", "create_numbered_clinet_certs" ]

attribute "openvpn/region",
  :display_name => "OpenVPN Region",
  :description => "OpenVPN Region",
  :required => "optional",
  :default => "default",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/routes",
  :display_name => "OpenVPN Routes",
  :description => "OpenVPN Routes",
  :required => "optional",
  :type => "array",
  :recipes => [ "openvpn::server" ]

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
