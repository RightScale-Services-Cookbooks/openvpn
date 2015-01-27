marker "openvpn reload start"

log "*** Reloading the openvpn service"

# the the service resource fails for :reload action. doing it in bash
bash "reload openvpn" do
  code <<-EOF
    service openvpn reload
  EOF
end

marker "openvpn reload end"
