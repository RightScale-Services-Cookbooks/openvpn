name             'openvpn'
maintainer       'RightScale Inc'
maintainer_email 'premium@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures openvpn'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.0'

depends "rightscale"
depends "sys_firewall"

# Core recipes
recipe "openvpn::default", "Install OpenVPN base software, needed for both client and server"
recipe "openvpn::server", "Install OpenVPN server software and generates certificates(keys) if not restored"
recipe "openvpn::client", "Installs OpenVPN client software, and downloads client certs"

# Client cert recipes
recipe "openvpn::create_numbered_client_certs", "Creates 'openvpn/client/count' numbered client certs starting from 'openvpn/client/count_start'"
recipe "openvpn::create_named_client_certs", "Creates named client certs"
recipe "openvpn::lighttpd", "Installs lighthttpd for serving certs"

# Backup and Restore recipes
recipe "openvpn::backup_certificates", "Creates a tarball with the OpenVPN certificates located in easy-rsa/keys folder and uploads it to Remote Object Storage"
recipe "openvpn::restore_certificates", "Restores from ROS the latest backup certificates tarball to the easy-rsa/keys OpenVPN folder"
recipe "openvpn::backup_schedule_enable", "Enables openvpn::backup_certificates to be run daily."
recipe "openvpn::backup_schedule_disable", "Disables openvpn::backup_certificates from being run daily."

#openvpn default
attribute "openvpn/client/host_prefix",
  :display_name => "OpenVPN Client Host Prefix",
  :description => "OpenVPN Client Certificate Host Prefix",
  :default => 'client', 
  :required => "optional",
  :recipes => [ "openvpn::create_named_client_certs", "openvpn::create_numbered_client_certs" ]

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
  :description => "One or a comma-separated list of client names to create openvpn certs for. Ex: john_doe,jane_doe",
  :default => "john_doe,jane_doe",
  :required => "optional",
  :recipes => [ "openvpn::create_named_client_certs" ]
  
attribute "openvpn/client/domain",
  :display_name => "OpenVPN Client Domain",
  :description => "OpenVPN Client Domain",
  :default => "example.com",
  :required => "optional",
  :recipes => [ "openvpn::client", "openvpn::create_named_client_certs", "openvpn::create_numbered_client_certs" ]

#openvpn server
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
  
# == OpenVPN ROS Backup/Restore attributes

attribute "openvpn/certificates_action",
  :display_name => "OpenVPN Certificates Action",
  :description =>
    "OpenVPN requires server and client certificates in order to work." +
    " These can be generated or restored from a Remote Object Store(ROS)." +
    " Use the 'Generate' option when setting up the OpenVPN server. " + 
	" To avoid having to update all the clients when the OpenVPN server is replaced," + 
	" use the 'Restore' option to populate the keys folder from a backup.",
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
 
