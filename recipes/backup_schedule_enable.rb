rightscale_marker :begin

bash "Creating /etc/cron.daily/vpn_backup" do
  flags "-ex"
  user "root"
  cwd "/tmp"
  code <<-EOH
cat << EOF > /etc/cron.daily/vpn_backup
#!/bin/sh
rs_run_recipe --name 'openvpn::backup_certificates' 2>&1 >> /var/log/rs_backup.log
exit 0
EOF

chmod +x /etc/cron.daily/vpn_backup
  EOH
end

rightscale_marker :end
