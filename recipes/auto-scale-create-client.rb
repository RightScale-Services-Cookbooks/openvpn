rightscale_marker :begin

remote_recipe "create-server-cert" do
  recipe "openvpn::client-cert-create"
  attributes { openvpn/client/count => 254,  openvpn/client/count_start => 254 }
  recipients_tags ["provides:monkey_type=wind_up", "provides:monkey_type=golden"]
end

rightscale_marker :end

