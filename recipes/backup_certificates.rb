rightscale_marker :begin

raise "*** ROS gem missing, please add rightscale::install_tools recipes to runlist." unless File.exists?("/opt/rightscale/sandbox/bin/ros_util")

log "*** In backup"

backupfilename = node[:openvpn][:backup][:lineage] + "-" + Time.now.strftime("%Y%m%d%H%M") + ".tar.gz"
backupfilepath = "/tmp/#{backupfilename}"

container = node[:openvpn][:backup][:container]
cloud = node[:openvpn][:backup][:storage_account_provider]

# Overrides default endpoint or for generic storage clouds such as Swift.
# Is set as ENV['STORAGE_OPTIONS'] for ros_util.
require 'json'

options =
  if node[:openvpn][:backup][:storage_account_endpoint].to_s.empty?
    {}
  else
    {'STORAGE_OPTIONS' => JSON.dump({
      :endpoint => node[:openvpn][:backup][:storage_account_endpoint],
      :cloud => node[:openvpn][:backup][:storage_account_provider].to_sym
    })}
  end

environment_variables = {
  'STORAGE_ACCOUNT_ID' => node[:openvpn][:backup][:storage_account_id],
  'STORAGE_ACCOUNT_SECRET' => node[:openvpn][:backup][:storage_account_secret]
}.merge(options)

bash "Create keys tarball to #{backupfilepath} " do
  flags "-ex"
  code <<-EOH
    tar -zcf #{backupfilepath} #{node[:openvpn][:key_dir]}
  EOH
end

# Upload the files to ROS
execute "Upload backupfile to Remote Object Store" do
  command "/opt/rightscale/sandbox/bin/ros_util put --cloud #{cloud} --container #{container} --dest #{backupfilename} --source #{backupfilepath}"
  environment environment_variables
end

# Delete the local file
file backupfilepath do
  backup false
  action :delete
end 

rightscale_marker :end
