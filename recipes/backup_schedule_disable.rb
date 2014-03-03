rightscale_marker :begin

log "*** Removing /etc/cron.daily/vpn_backup if exists"
system('rm -rf /etc/cron.daily/vpn_backup')

rightscale_marker :end
