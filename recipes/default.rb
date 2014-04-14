#
# Cookbook Name:: openvpn
# Recipe:: default
#
# Copyright 2014, RightScale Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

rightscale_marker :begin

# Make sure the latest openssl package is installed for the CVE-2014-0160 vulnerability
package "openssl" do
  action :upgrade
end

package "openvpn" do
  action :install
end

case node[:platform]
when 'centos', 'redhat'
  log "*** Installing easy-rsa and lzo"
  package "easy-rsa"
  package "lzo"
when 'ubuntu', 'debian'
  log "*** easy-rsa is already installed, linking under /usr/share/easy-rsa"
  link "/usr/share/easy-rsa" do
    to "/usr/share/doc/openvpn/examples/easy-rsa"
  end
else
  raise "*** Unsupported platform '#{node[:platform]}'"
end

chef_gem "netaddr" do
  action :install
end

directory node[:openvpn][:log_dir] do
  owner "root"
  group "root"
  mode "0777"
  recursive true
  action :create
end

directory node[:openvpn][:key_dir] do
  owner "root"
  group "root"
  mode "0777"
  recursive true
  action :create
end

easy_rsa_dir="/etc/openvpn/easy-rsa/"
execute "cp -R /usr/share/easy-rsa/2.0/* #{easy_rsa_dir}"

log "*** Patching whichopensslcnf if needed, making alnum optional"
execute "sed -i -r 's/(\\[\\[:digit:\\]\\]\\[\\[:alnum:\\]\\])([^\\?])/\\1\\?\\2/' #{easy_rsa_dir}whichopensslcnf"
   
rightscale_marker :end 
