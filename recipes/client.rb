rightscale_marker :begin
require 'netaddr'
subnet=NetAddr::CIDR.create("#{node[:openvpn][:server][:network_prefix]} #{node[:openvpn][:server][:subnet_mask]}").netmask.split('/').last

easy_rsa_dir="/etc/openvpn/easy-rsa/"
execute "cp -R /usr/share/easy-rsa/2.0/* #{easy_rsa_dir}"

remote_file "#{easy_rsa_dir}/keys/ca.crt" do
  source "#{node[:openvpn][:client][:key_base_url]}/ca.crt"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

remote_file "#{easy_rsa_dir}/keys/client.crt" do
  source "#{node[:openvpn][:client][:key_base_url]}/#{node[:openvpn][:client][:host_prefix]}-#{node[:openvpn][:client][:host_number]}.#{node[:openvpn][:client][:domain]}.crt"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

remote_file "#{easy_rsa_dir}/keys/client.key" do
  source "#{node[:openvpn][:client][:key_base_url]}/#{node[:openvpn][:client][:host_prefix]}-#{node[:openvpn][:client][:host_number]}.#{node[:openvpn][:client][:domain]}.key"
  owner "root"
  group "root"
  mode "0644"
  action :create
end


template "/etc/openvpn/client.conf" do
  source "client.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables( :key_dir => node[:openvpn][:key_dir],
             :log_dir => node[:openvpn][:log_dir],
             :cipher => node[:openvpn][:cipher],
             :network_prefix => node[:openvpn][:server][:network_prefix],
             :subnet_mask => node[:openvpn][:server][:subnet_mask],
             :client_count => node[:openvpn][:client][:count]
            )
  action :create
end

service "openvpn" do
  action :start
end

sys_firewall "1194" do
  protocol "both"
  action :update
end

rightscale_marker :end             
