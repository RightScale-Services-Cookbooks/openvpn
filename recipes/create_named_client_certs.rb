rightscale_marker :begin

if ("#{node[:openvpn][:client][:names]}" == "")
  raise "*** Input openvpn/client/names is undefined, aborting"
end

log "*** Setting up client certificates in /etc/openvpn/easy-rsa/keys/"
log "*** Client names: #{node[:openvpn][:client][:names]}"

existing_clients=`grep '^V' /etc/openvpn/easy-rsa/keys/index.txt | sed -r 's/.*name=([^/]+).*/\\1/g' | grep -v '^server$'`.split(/\s*\n\s*/)

node[:openvpn][:client][:names].split(/\s*,\s*/).each do |i|
  name="named_client-#{i}"
  if (existing_clients.include? name)
    log "*** Client #{name} already exists, skipping..."
    existing_clients.delete(name)
  else
    log "*** Client #{name} doesn't exist, adding..."
    bash "create client" do
      cwd "/etc/openvpn/easy-rsa"
      code <<-EOF
        echo "*** Sourcing /etc/openvpn/easy-rsa/vars"
        source ./vars > /dev/null
        export KEY_CN="#{name}"
        export EASY_RSA="${EASY_RSA:-.}"
        export KEY_NAME="#{name}"

        echo "*** Running $EASY_RSA/pkitool"
        "$EASY_RSA/pkitool" --batch "#{name}"

        if [ -d /var/www/lighttpd/secure ] ; then
          echo "*** Creating /var/www/lighttpd/secure/#{name}.tar"
          tar -cf /var/www/lighttpd/secure/#{name}.tar keys/#{name}.crt keys/#{name}.key keys/ca.crt
        else
          echo "*** /var/www/lighttpd/secure/ is missing, skipping the tarball creation"
        fi
      EOF
    end
  end
end

existing_clients.each do  |name|
  log "*** Client #{name} already exists, but no longer required, revoking..."
  bash "create client" do
    cwd "/etc/openvpn/easy-rsa"
    code <<-EOF
      echo "*** Sourcing /etc/openvpn/easy-rsa/vars"
      source ./vars > /dev/null
      echo "*** Running $EASY_RSA/revoke-full "
      ./revoke-full "#{name}" | grep "certificate revoked"
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

rightscale_marker :end
