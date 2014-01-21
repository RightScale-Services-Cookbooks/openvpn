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

attribute "openvpn/server",
  :display_name => "OpenVPN Server",
  :description => "OpenVPN Server",
  :recipes => [ "openvpn::client" ]

attribute "openvpn/client/key_base_url",
  :display_name => "OpenVPN Client Package Base URL",
  :description => "OpenVPN Client Package Base URL",
  :recipes => [ "openvpn::client" ]
