openvpn Cookbook
================

Provides recipes and erb templates to install and configure OpenVPN servers and clients. It also contains recipes to help manage(add, remove) client certificates and backup/restore the keys to Remote Object Storage(ex: AWS S3)


Requirements
------------
TODO: List your cookbook requirements. Be sure to include any requirements this cookbook has on platforms, libraries, other cookbooks, packages, operating systems, etc.

#### cookbooks

- `rightscale` - needed to delimit recipes output using rightscale_markers
- `sys_firewall` - needed to update the iptables firewall with the ports needed by OpenVPN

#### packages
- `easy-rsa` - helper scripts to manage RSA certificates used by OpenVPN
- `lzo` - a real-time data compression library used by OpenVPN
- `netaddr` - ruby gem to manipulate network addresses

Attributes
----------
TODO: List you cookbook attributes here.


Usage
-----
#### openvpn::default
TODO: Write usage instructions for each cookbook.

Contributing
------------

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github
