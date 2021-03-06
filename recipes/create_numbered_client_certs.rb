rightscale_marker :begin

log node[:openvpn][:client][:count].to_i
log node[:openvpn][:client][:host_prefix]

for i in node[:openvpn][:client][:count_start].to_i..node[:openvpn][:client][:count].to_i 
  name="numbered_client-#{i+1}"

  log "*** Creating client cert /etc/openvpn/easy-rsa/keys/#{name}.*"
  bash "create client" do
    cwd "/etc/openvpn/easy-rsa"
    code <<-EOF
      echo "*** Sourcing /etc/openvpn/easy-rsa/vars" 
      source ./vars > /dev/null
      export KEY_CN=#{name}
      export EASY_RSA="${EASY_RSA:-.}"
      export KEY_NAME="#{name}"

      echo "*** Running $EASY_RSA/pkitool"
      "$EASY_RSA/pkitool" --batch #{name}

      if [ -d /var/www/lighttpd/secure ] ; then
        echo "*** Creating /var/www/lighttpd/secure/#{name}.tar" 
        tar -cf /var/www/lighttpd/secure/#{name}.tar keys/#{name}.crt keys/#{name}.key keys/ca.crt
      else
        echo "*** /var/www/lighttpd/secure/ is missing, skipping the tarball creation"
      fi
    EOF
  end
end

log "*** Reloading the openvpn service to pick up the new client keys"
#the the service resource fails for :reload action
bash "reload openvpn" do
  code <<-EOF
    service openvpn reload
  EOF
end

rightscale_marker :end
