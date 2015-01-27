marker "openvpn backup_schedule_disable start"

log "*** Removing /etc/cron.daily/vpn_backup if exists"
system('rm -rf /etc/cron.daily/vpn_backup')

marker "openvpn backup_schedule_disable end"
