name             'openvpn'
maintainer       'RightScale Inc'
maintainer_email 'support@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures openvpn'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.4'

depends "rightscale"
depends "sys_firewall"

# Core recipes
recipe "openvpn::default", "Install OpenVPN base software, needed for both client and server"
recipe "openvpn::server", "Install OpenVPN server software and generate certificates(keys) if not restored from ROS"
recipe "openvpn::client_url_certs", "Installs OpenVPN client software, and downloads client certs"
recipe "openvpn::client_input_certs", "Installs OpenVPN client software, and deploys client certs using inputs"

# Client cert recipes
recipe "openvpn::create_numbered_client_certs", "Creates 'openvpn/client/count' numbered client certs starting from 'openvpn/client/count_start'"
recipe "openvpn::manage_named_client_certs", "Manage(create or revoke) certificates. The names input should contain all names to be allowed. To create a new certificate, add the name to the list in the input. To revoke a client, remove the name from the list. Then, run the recipe to sync."
recipe "openvpn::lighttpd", "Installs lighthttpd for serving certs"

# Backup and Restore recipes
recipe "openvpn::backup_certificates", "Creates an OpenVPN certificates tarball and uploads it to Remote Object Storage"
recipe "openvpn::restore_certificates", "Restores the latest backup certificates tarball from ROS to the easy-rsa/keys OpenVPN folder"
recipe "openvpn::backup_schedule_enable", "Enables openvpn::backup_certificates to be run daily."
recipe "openvpn::backup_schedule_disable", "Disables openvpn::backup_certificates from being run daily."
recipe "openvpn::restart", "Restarts the openvpn service."
recipe "openvpn::reload", "Reloads the openvpn service."

# OpenVPN attributes
attribute "openvpn/client/count_start",
  :display_name => "OpenVPN Client First Host Number",
  :description => "OpenVPN Client First Host Number",
  :default => "1", 
  :required => "optional",
  :recipes => [ "openvpn::create_numbered_client_certs" ]

attribute "openvpn/client/count",
  :display_name => "OpenVPN Client Count",
  :description => "Number of OpenVPN Client Certs to Create",
  :default => "20",
  :required => "optional",
  :recipes => [ "openvpn::create_numbered_client_certs" ]
  
attribute "openvpn/client/names",
  :display_name => "OpenVPN Client Name(s)",
  :description => "One or a comma-separated list of client names. This input should contain all names to be allowed using client certificates. To create a new certificate, add the name to the list. To revoke a client, remove the name from the list. Example: john_doe,jane_doe",
  :required => "required",
  :recipes => [ "openvpn::manage_named_client_certs" ]
  
attribute "openvpn/client/cert_name",
  :display_name => "OpenVPN Client Cert Name",
  :description => "The OpenVPN Client Certificate name as it is found in the easy-rsa/keys folder. For example: named_client-john_doe",
  :required => "required",
  :recipes => [ "openvpn::client_url_certs" ]

#openvpn server
attribute "openvpn/server/max_clients",
  :display_name => "OpenVPN Max Clients",
  :description => "The maximum number of concurrently connected OpenVPN clients to allow. Example: 128",
  :default => "128",
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/region",
  :display_name => "OpenVPN Region",
  :description => "OpenVPN Region",
  :required => "optional",
  :default => "default",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/server/routes",
  :display_name => "OpenVPN Routes",
  :description => "OpenVPN Routes to be pushed to the client config. Use a comma-separated list of IP NETMASK pairs. For example: 10.0.0.0 255.0.0.0,192.168.40.0 255.255.255.0",
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/server/network_prefix",
  :display_name => "OpenVPN Network Prefix",
  :description => "OpenVPN IP Network Prefix. For example: 192.168.111.0",
  :default => '192.168.111.0',
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/server/subnet_mask",
  :display_name => "OpenVPN Subnet Mask",
  :description => "OpenVPN Subnet Mask. For example: 255.255.255.0",
  :default =>  '255.255.255.0',
  :required => "optional",
  :recipes => [ "openvpn::server" ]
  
attribute "openvpn/server/port",
  :display_name => "OpenVPN Server Port",
  :description => "OpenVPN Server listening port. Example: 1194",
  :default => "1194",
  :required => "optional",
  :recipes => [ "openvpn::server", "openvpn::client_url_certs", "openvpn::client_input_certs" ]
  
attribute "openvpn/server/proto",
  :display_name => "OpenVPN Server Proto",
  :description => "OpenVPN Server protocol. Example: UDP",
  :default => "UDP",
  :choice => [ "UDP", "TCP" ],
  :required => "optional",
  :recipes => [ "openvpn::server", "openvpn::client_url_certs", "openvpn::client_input_certs" ]

attribute "openvpn/client/ca_crt",
  :display_name => "OpenVPN Client CA Cert",
  :description => "OpenVPN value for the keys/ca.crt file. Same as the value used by the OpenVPN server",
  :required => "required",
  :recipes => [ "openvpn::client_input_certs" ]

attribute "openvpn/client/client_crt",
  :display_name => "OpenVPN Client Certificate",
  :description => "OpenVPN value for the keys/client.crt file. This must be generated on the server for each client",
  :required => "required",
  :recipes => [ "openvpn::client_input_certs" ]
  
attribute "openvpn/client/client_key",
  :display_name => "OpenVPN Client Key",
  :description => "OpenVPN value for the keys/client.key file. This must be generated on the server for each client",
  :required => "required",
  :recipes => [ "openvpn::client_input_certs" ]

#openvpn cert inputs  
attribute "openvpn/cert/country",
  :display_name => "OpenVPN Cert Country",
  :description => "OpenVPN Country to use when generating the server and client certificates. Example: US",
  :default =>  'US',
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/cert/province",
  :display_name => "OpenVPN Cert Province",
  :description => "OpenVPN Province to use when generating the server and client certificates. Example: CA",
  :default =>  "CA",
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/cert/city",
  :display_name => "OpenVPN Cert City",
  :description => "OpenVPN City to use when generating the server and client certificates. Example: San Francisco",
  :default =>  "San Francisco",
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/cert/org",
  :display_name => "OpenVPN Cert Organization",
  :description => "OpenVPN Organization to use when generating the server and client certificates. Example: Example Widgets Inc",
  :default =>  "Example Widgets Inc",
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/cert/email",
  :display_name => "OpenVPN Cert Email",
  :description => "OpenVPN Email to use when generating the server and client certificates. Example: root@example.com",
  :default =>  "root@example.com",
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/cert/cn",
  :display_name => "OpenVPN Cert Common Name",
  :description => "OpenVPN Common Name to use when generating the server and client certificates. Example: openvpn-server.example.com",
  :default =>  "openvpn-server.example.com",
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/cert/ou",
  :display_name => "OpenVPN Cert Organizational Unit",
  :description => "OpenVPN Organizational Unit to use when generating the server and client certificates. Example: IT",
  :default =>  "IT",
  :required => "optional",
  :recipes => [ "openvpn::server" ]
  
attribute "openvpn/server/c2c",
  :display_name => "OpenVPN Client To Client",
  :description => "Set to true if you would like connecting clients to be able to reach each other over the VPN. By default, clients will only be able to reach the server",
  :default => "false",
  :choice => [ "false", "true" ],
  :required => "optional",
  :recipes => [ "openvpn::server" ]

attribute "openvpn/server/additional",
  :display_name => "OpenVPN Additional Configs",
  :description => "Use this input to pass one or multiple newline-separated config items to the OpenVPN server.conf. Example: push \"redirect-gateway def1 bypass-dhcp\"",
  :required => "optional",
  :recipes => [ "openvpn::server" ]

#openvpn client
attribute "openvpn/server/hostname",
  :display_name => "OpenVPN Server",
  :description => "OpenVPN Server Hostname or IP. Example: openvpn-server.example.com",
  :required => "required",
  :recipes => [ "openvpn::client_url_certs", "openvpn::client_input_certs" ]

attribute "openvpn/client/key_base_url",
  :display_name => "OpenVPN Client Package Base URL",
  :description => "OpenVPN Client Package Base URL",
  :required => "required",
  :recipes => [ "openvpn::client_url_certs" ]

attribute "openvpn/client/host_number",
  :display_name => "OpenVPN Client Host Number",
  :description => "OpenVPN Client Host Number",
  :required => "required",
  :recipes => [ "openvpn::client_url_certs" ]
  
# == OpenVPN ROS Backup/Restore attributes

attribute "openvpn/certificates_action",
  :display_name => "OpenVPN Certificates Action",
  :description =>
    "OpenVPN requires server and client certificates in order to work." +
    " These can be generated or restored from a Remote Object Store(ROS)." +
    " Use the 'Generate' option when setting up the OpenVPN server. " + 
    " To avoid having to update all the clients when the OpenVPN server is replaced," + 
    " use the 'Restore' option to populate the keys folder from a backup." +
    " For the certificates backup and restore recipes to work, the optional 'backup' " + 
    " advanced inputs must be defined.",
  :required => "required",
  :choice => [ "Generate", "Restore" ],
  :recipes => [
    "openvpn::restore_certificates",
	"openvpn::server"
  ]

attribute "openvpn/backup/lineage",
  :display_name => "OpenVPN Backup Lineage",
  :description =>
    "The prefix that will be used to name/locate the backup of a particular" +
    " VPN server. Example: text: companyx_certs",
  :required => "optional",
  :recipes => [
    "openvpn::backup_certificates",
    "openvpn::restore_certificates",
	"openvpn::backup_schedule_enable"
  ]

attribute "openvpn/backup",
  :display_name => "Import/export settings for database dump file management.",
  :type => "hash"

attribute "openvpn/backup/storage_account_provider",
  :display_name => "Dump Storage Account Provider",
  :description =>
    "Location where the dump file will be saved." +
    " Used by dump recipes to back up to remote object storage" +
    " (complete list of supported storage locations is in input dropdown)." +
    " Example: s3",
  :required => "optional",
  :choice => [
    "s3",
    "Cloud_Files",
    "Cloud_Files_UK",
    "google",
    "azure",
    "swift",
    "SoftLayer_Dallas",
    "SoftLayer_Singapore",
    "SoftLayer_Amsterdam"
  ],
  :recipes => [
    "openvpn::backup_certificates",
    "openvpn::restore_certificates",
	"openvpn::backup_schedule_enable"
  ]

attribute "openvpn/backup/storage_account_id",
  :display_name => "OpenVPN Backup Storage Account ID",
  :description =>
    "In order to write the OpenVPN backup file to the specified cloud storage location," +
    " you need to provide cloud authentication credentials." +
    " For Amazon S3, use your Amazon access key ID" +
    " (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your" +
    " Rackspace login username (e.g., cred:RACKSPACE_USERNAME)." +
    " For OpenStack Swift the format is: 'tenantID:username'." +
    " Example: cred:AWS_ACCESS_KEY_ID",
  :required => "optional",
  :recipes => [
    "openvpn::backup_certificates",
    "openvpn::restore_certificates",
	"openvpn::backup_schedule_enable"
  ]

attribute "openvpn/backup/storage_account_secret",
  :display_name => "OpenVPN Backup Storage Account Secret",
  :description =>
    "In order to write the OpenVPN backup file to the specified cloud storage location," +
    " you need to provide cloud authentication credentials." +
    " For Amazon S3, use your AWS secret access key" +
    " (e.g., cred:AWS_SECRET_ACCESS_KEY)." +
    " For Rackspace Cloud Files, use your Rackspace account API key" +
    " (e.g., cred:RACKSPACE_AUTH_KEY). Example: cred:AWS_SECRET_ACCESS_KEY",
  :required => "optional",
  :recipes => [
    "openvpn::backup_certificates",
    "openvpn::restore_certificates",
	"openvpn::backup_schedule_enable"
  ]

attribute "openvpn/backup/storage_account_endpoint",
  :display_name => "OpenVPN Backup Storage Endpoint URL",
  :description =>
    "The endpoint URL for the storage cloud. This is used to override the" +
    " default endpoint or for generic storage clouds such as Swift." +
    " Example: http://endpoint_ip:5000/v2.0/tokens",
  :required => "optional",
  :default => "",
  :recipes => [
    "openvpn::backup_certificates",
    "openvpn::restore_certificates",
	"openvpn::backup_schedule_enable"
  ]

attribute "openvpn/backup/container",
  :display_name => "OpenVPN Backup Container",
  :description =>
    "The cloud storage location where the dump file will be saved to" +
    " or restored from. For Amazon S3, use the bucket name." +
    " For Rackspace Cloud Files, use the container name." +
    " Example: db_dump_bucket",
  :required => "optional",
  :recipes => [
    "openvpn::backup_certificates",
    "openvpn::restore_certificates",
	"openvpn::backup_schedule_enable"
  ]
 
