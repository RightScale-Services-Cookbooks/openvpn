rightscale_marker :begin

require 'netaddr'
subnet=NetAddr::CIDR.create("#{node[:openvpn][:server][:network_prefix]} #{node[:openvpn][:server][:subnet_mask]}").netmask.split('/').last

log "*** Using subnet: #{subnet}"

if (subnet)
  template "/etc/iptables.snat" do
    source "iptables.snat.erb"
    owner  "root"
    group  "root"
    mode   "0644"
    variables( :cidr => "#{node[:openvpn][:server][:network_prefix]}/#{subnet}" )
    action :create
  end
else
  raise "*** subnet is undefined, aborting"
end

easy_rsa_dir="/etc/openvpn/easy-rsa/"
execute "cp -R /usr/share/easy-rsa/2.0/* #{easy_rsa_dir}"

template "#{easy_rsa_dir}/vars" do
  source "vars.erb"
  owner "root"
  group "root"
  mode "0755"
  variables(
    :country => node[:openvpn][:cert][:country],
    :province => node[:openvpn][:cert][:province],
    :city => node[:openvpn][:cert][:city],
    :org => node[:openvpn][:cert][:org],
    :email => node[:openvpn][:cert][:email],
    :cn => node[:openvpn][:cert][:cn],
    :name => node[:openvpn][:cert][:name],
    :ou => node[:openvpn][:cert][:ou]
  )
  action :create
end

%w{ build-ca  build-dh  build-key  build-key-server }.each do |rsa_file|
  cookbook_file "#{easy_rsa_dir}/#{rsa_file}" do
    source rsa_file
    owner "root"
    group "root"
    mode "0755"
    action :create
  end
end

if ("#{node[:openvpn][:certificates_action]}" == "Generate")
  log "*** Generating OpenVPN keys as attribute openvpn/certificates_action is set to 'Generate'"
  directory "#{node[:openvpn][:key_dir]}" do
    owner "root"
    group "root"
    mode 0777
    action :create
  end

  bash "build keys" do
    cwd "#{easy_rsa_dir}"
    code <<-EOF
      echo "*** Generating the server keys"
      source ./vars
      ./clean-all
      ./build-ca 
      #./build-key-server server
      ./build-dh
    EOF
  end
  
  log "*** Creating dummy crl.pem to allow the openvpn service to start. This file is used for revoked clients"
  template "#{easy_rsa_dir}/keys/crl.pem" do
    source "crl.pem.erb"
    owner "root"
    group "root"
    mode "0644"
    action :create
  end
else
  log "*** Not generating OpenVPN keys as attribute openvpn/certificates_action is not set to 'Generate'"
end


template "/etc/openvpn/server.conf" do
  source "server.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :key_dir => node[:openvpn][:key_dir],
    :log_dir => node[:openvpn][:log_dir],
    :cipher => node[:openvpn][:cipher],
    :network_prefix => node[:openvpn][:server][:network_prefix],
    :subnet_mask => node[:openvpn][:server][:subnet_mask],
    :client_count => node[:openvpn][:server][:max_clients],
    :private_ip => node[:cloud][:private_ips][0],
    :routes => node[:openvpn][:routes].split(/\s*,\s*/)
  )
  action :create
end

sys_firewall "1194" do
  protocol "udp"
  action :update
end

right_link_tag "provides:openvpn=server" do
  action :publish
end

right_link_tag "openvpn:region=#{node[:openvpn][:region]}" do
  action :publish
end

bash "net.ipv4.ip_forward update" do
  flags "-ex"
  user "root"
  cwd "/tmp"
  code <<-EOH
    echo 1 > /proc/sys/net/ipv4/ip_forward
    sed -i -r 's/.*net\.ipv4\.ip_forward.+/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
  EOH
end

# sys_firewall::default disables iptables when node[:sys_firewall][:enabled]==disabled
bash "iptables-restore" do
  flags "-ex"
  user "root"
  cwd "/tmp"
  code <<-EOH
    if [ -f "/etc/iptables.snat" ]; then
      iptables-restore < /etc/iptables.snat
    fi
  EOH
end

ohai "reload" do
  action :nothing
end

right_link_tag "openvpn:network=#{node[:openvpn][:server][:network_prefix]}/#{subnet}" do
  action :publish
end

service "openvpn" do
  action [ :enable, :start ]
  notifies :reload, "ohai[reload]"
end

rightscale_marker :end
