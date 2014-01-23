rightscale_marker :begin

easy_rsa_dir="/etc/openvpn/easy-rsa/"
execute "cp -R /usr/share/easy-rsa/2.0/* #{easy_rsa_dir}"

remote_file "#{easy_rsa_dir}/client.tar" do
  source "#{node[:openvpn][:client][:key_base_url]}/#{node[:openvpn][:client][:host_prefix]}-#{node[:openvpn][:client][:host_number]}.#{node[:openvpn][:client][:domain]}.tar"
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
  variables( :key_dir => node[:openvpn][:key_dir],
             :log_dir => node[:openvpn][:log_dir],
             :cipher => node[:openvpn][:cipher],
             :network_prefix => node[:openvpn][:server][:network_prefix],
             :subnet_mask => node[:openvpn][:server][:subnet_mask],
             :client_count => node[:openvpn][:client][:count],
             :server => node[:openvpn][:server],
             :hostname => "#{node[:openvpn][:client][:host_prefix]}-#{node[:openvpn][:client][:host_number]}.#{node[:openvpn][:client][:domain]}"
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

#ruby_block "set-ip-tag" do
#  block do
#    require 'rubygems'
#    require 'json'
#    require 'ohai'
#
#    system = Ohai::System.new
#    system.all_plugins
#    node1=JSON.parse(system.to_json)
#    puts node1
#    Chef::ShellOut.new("/usr/bin/rs_tag --add openvpn::ip=#{node1["network"]["interfaces"]["tun0"]["addresses"].first.first}").run_command
#  end
#end

rightscale_marker :end             
