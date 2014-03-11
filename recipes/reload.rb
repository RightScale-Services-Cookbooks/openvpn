rightscale_marker :begin

log "*** Reloading the openvpn service"

# the the service resource fails for :reload action. doing it in bash
bash "reload openvpn" do
  code <<-EOF
    service openvpn reload
  EOF
end

rightscale_marker :end
