rightscale_marker :begin

cat << EOF > /etc/cron.daily/vpn_backup
#!/bin/bash
command "rs_run_recipe --name 'backup_certificates' 2>&1 >> /var/log/rs_backup.log"
EOF

rightscale_marker :end
