log node[:openvpn][:client][:count].to_i
log node[:openvpn][:client][:host_prefix]

for i in node[:openvpn][:client][:count_start].to_i..node[:openvpn][:client][:count].to_i 
  name="#{node[:openvpn][:client][:host_prefix]}-#{i+1}.#{node[:openvpn][:client][:domain]}"

  bash "create client" do
    cwd "/etc/openvpn/easy-rsa"
    code <<-EOF
      echo "*** Sourcing /etc/openvpn/easy-rsa/vars" 
      source ./vars > /dev/null
      export KEY_CN=#{name}
      export EASY_RSA="${EASY_RSA:-.}"

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
