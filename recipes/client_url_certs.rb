rightscale_marker :begin

easy_rsa_dir="/etc/openvpn/easy-rsa/"

remote_file "#{easy_rsa_dir}/client.tar" do
  source "#{node[:openvpn][:client][:key_base_url]}/#{node[:openvpn][:client][:cert_name]}.tar"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

execute "tar -xf #{easy_rsa_dir}/client.tar -C #{easy_rsa_dir}"

template "/etc/openvpn/client.conf" do
  source "client.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables( :port => node[:openvpn][:server][:port],
             :proto => node[:openvpn][:server][:proto].downcase,
             :key_dir => node[:openvpn][:key_dir],
             :log_dir => node[:openvpn][:log_dir],
             :cipher => node[:openvpn][:cipher],
             :network_prefix => node[:openvpn][:server][:network_prefix],
             :subnet_mask => node[:openvpn][:server][:subnet_mask],
             :client_count => node[:openvpn][:client][:count],
             :server => node[:openvpn][:server],
             :cert => node[:openvpn][:client][:cert_name]
            )
  action :create
end

service "openvpn" do
  action :start
end

sys_firewall node[:openvpn][:server][:port] do
  protocol node[:openvpn][:server][:proto].downcase
  action :update
end

right_link_tag "openvpn:client_number=#{node[:openvpn][:client][:host_number]}" do
  action :publish
end
rightscale_marker :end             
