rightscale_marker :begin

easy_rsa_dir="/etc/openvpn/easy-rsa/"

file "#{easy_rsa_dir}keys/ca.crt" do
  content node[:openvpn][:client][:ca_crt]
  mode 00600
end

file "#{easy_rsa_dir}keys/client.crt" do
  content node[:openvpn][:client][:client_crt]
  mode 00600
end

file "#{easy_rsa_dir}keys/client.key" do
  content node[:openvpn][:client][:client_key]
  mode 00600
end

log "*** Creating client.conf for remote openvpn server(#{node[:openvpn][:server]}) over #{node[:openvpn][:server][:proto]}/#{node[:openvpn][:server][:port]}"

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
             :server => node[:openvpn][:server],
             :cert => "client"
            )
  action :create
end

sys_firewall node[:openvpn][:server][:port] do
  protocol node[:openvpn][:server][:proto].downcase
  action :update
end

service "openvpn" do
  action :start
end

rightscale_marker :end           
