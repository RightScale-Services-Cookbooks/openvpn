subnet=NetAddr::CIDR.create("#{node[:openvpn][:server][:network_prefix]} #{node[:openvpn][:server][:subnet_mask]}").netmask.split('/').last

easy_rsa_dir="/etc/openvpn/easy-rsa/"
execute "cp -R /usr/share/easy-rsa/2.0/* #{easy_rsa_dir}"

template "#{easy_rsa_dir}/vars" do
  source "vars.erb"
  owner "root"
  group "root"
  mode "0755"
  variables => ({
                  :country => node[:openvpn][:cert][:country],
                  :province => node[:openvpn][:cert][:province],
                  :city => node[:openvpn][:cert][:city],
                  :org => node[:openvpn][:cert][:org],
                  :email => node[:openvpn][:cert][:email],
                  :cn => node[:openvpn][:cert][:cn],
                  :name => node[:openvpn][:cert][:name],
                  :ou => node[:openvpn][:cert][:ou]
                })
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

bash "build keys" do
  cwd "#{easy_rsa_dir}"
  code <<-EOF
    source ./vars
    ./clean-all
    ./build-ca 
    ./build-key-server server
    ./build-dh
  EOF
end
