if ("#{node[:openvpn][:client][:names]}" == "")
  raise "*** Input openvpn/client/names is undefined, aborting"
end

node[:openvpn][:client][:names].split(/\s*,\s*/).each do |i|
  name="named_client-#{i}"

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
#the the service resource fails for :reload action. Doing it the proper way :)
bash "reload openvpn" do
  code <<-EOF
    service openvpn reload
  EOF
end
