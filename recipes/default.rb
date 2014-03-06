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

package "openvpn" do
  action :install
end

#Ubuntu easy-rsa
link "/usr/share/easy-rsa" do
  to "/usr/share/doc/openvpn/examples/easy-rsa"
end if (File.exists?("/usr/share/doc/openvpn/examples/easy-rsa") && !File.exists?("/usr/share/easy-rsa"))

# CentOS easy-rsa
# This will install easy-rsa under /usr/share/easy-rsa
package "easy-rsa" do
  action :install
end unless File.exists?("/usr/share/easy-rsa")

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
   
rightscale_marker :end 
