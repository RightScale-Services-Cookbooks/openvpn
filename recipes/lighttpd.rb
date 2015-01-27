marker "openvpn lighttpd start"

package "lighttpd" do
  action :install
end

if node[:openvpn][:lighttpd][:dir_listing] == "enable"
  execute "sed -i -e 's/dir-listing.activate      = \"disable\"/dir-listing.activate      = \"enable\"/' /etc/lighttpd/conf.d/dirlisting.conf"
end

service "lighttpd" do
  action :start
end

directory "/var/www/lighttpd/secure" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

marker "openvpn lighttpd end"
