rightscale_marker :begin

package "lighttpd" do
  action :install
end

if node[:openvpn][:lighttpd][:dir_listing] == "enable"
  execute "sed -i -e 's/dir-listing.activate      = \"disable\"/dir-listing.activate      = \"enable\"/' /etc/lighttpd/conf.d/dirlisting.conf"
end

link "/var/www/lighttpd/secure" do
  to "/etc/openvpn/easy-rsa/keys"
  link_type :symbolic
end

sys_firewall "80"

service "lighttpd" do
  action :start
end
#directory "/var/www/lighttpd/secure" do
#  owner "root"
#  group "root"
#  mode "0755"
#  action :create
#end
#
rightscale_marker :end
