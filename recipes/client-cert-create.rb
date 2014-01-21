for i in 0..node[:openvpn][:client][:count].to_i 
  name="#{[:openvpn][:client][:host_prefix]}-#{i+1}.#{node[:openvpn][:client][:domain]}"

  bash "create client" do
    cwd "/etc/openvpn/easy-rsa"
    code <<-EOF
      source ./vars > /dev/null
      export KEY_CN=#{name}
      export EASY_RSA="${EASY_RSA:-.}"
      "$EASY_RSA/pkitool" --batch #{name}
      tar -cf /var/www/lighttpd/secure/#{name}.tar keys/#{name}.crt keys/#{name}.key keys/ca.crt 
    EOF
  end
end
