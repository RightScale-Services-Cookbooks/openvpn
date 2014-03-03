rightscale_marker :begin

log "*** In openvpn::restore_certificates"

raise "*** ROS gem missing, please add rightscale::install_tools recipes to runlist." unless File.exists?("/opt/rightscale/sandbox/bin/ros_util")

if ("#{node[:openvpn][:certificates_action]}" != "Restore")
  log "*** Skipping OpenVPN restore as attribute openvpn/certificates_action is not 'Restore'"
  return
end

if (("#{node[:openvpn][:backup][:storage_account_id]}" == "") ||
    ("#{node[:openvpn][:backup][:storage_account_secret]}" == "") ||
    ("#{node[:openvpn][:backup][:container]}" == "") ||
    ("#{node[:openvpn][:backup][:lineage]}" == ""))
  raise "*** Attributes openvpn/backup/storage_account_id, storage_account_secret, container and lineage are required by openvpn::restore_certificates. Aborting"
end

if File.directory?(node[:openvpn][:key_dir])
  log "*** Skipping OpenVPN certificates restore as this folder already exists: #{node[:openvpn][:key_dir]}"
else
  log "*** #{node[:openvpn][:key_dir]} is missing, restoring it from ROS"
  prefix = node[:openvpn][:backup][:lineage]
  backupfilepath_without_extension = "/tmp/" + prefix
  container = node[:openvpn][:backup][:container]
  cloud = node[:openvpn][:backup][:storage_account_provider]
  command_to_execute = "/opt/rightscale/sandbox/bin/ros_util get" +
    " --cloud #{cloud} --container #{container}" +
    " --dest #{backupfilepath_without_extension}" +
    " --source #{prefix} --latest"

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

  # Obtain the backup file from ROS
  execute "Download the backup file from Remote Object Store" do
    command command_to_execute
    creates backupfilepath_without_extension
    environment environment_variables
  end

  bash "Restore keys tarball(#{backupfilepath_without_extension})" do
    flags "-ex"
    code <<-EOH
      cd /
      tar -xzf #{backupfilepath_without_extension}
      echo "*** Removing #{backupfilepath_without_extension}"
      rm -rf #{backupfilepath_without_extension}
    EOH
  end
end 

rightscale_marker :end
