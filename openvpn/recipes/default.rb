package "openvpn" do
  action :install
end

service "openvpn" do
  action :nothing
end

remote_directory "/etc/openvpn/keys" do
  source "keys"
  files_backup 0
  files_owner "root"
  files_group "root"
  files_mode 0600
  owner "root"
  group "root"
  mode 0700
end

remote_directory "/etc/openvpn/easy-rsa" do
  source "easy-rsa"
  files_backup 0
  files_owner "root"
  files_group "root"
  files_mode 0700
  owner "root"
  group "root"
  mode 0700
end
  
template "/etc/openvpn/server.up.sh" do
  source "server.up.sh.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "openvpn"), :delayed
end

template "/etc/openvpn/server.conf" do
  source "server.conf.erb"
  variables :openvpn => node[:openvpn]
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "openvpn"), :delayed
end
