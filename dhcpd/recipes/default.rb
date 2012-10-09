#
# Cookbook Name:: dhcpd
# Recipe:: default
#
# Copyright 2010, 37signals
#
# All rights reserved - Do Not Redistribute
#

package "dhcp3-server"
service "dhcp3-server"

template "/etc/default/dhcp3-server" do
  source "dhcp3-server.default.erb"
  owner "root"
  group "root"
  mode 0644
  notifies(:restart, resources(:service => "dhcp3-server"))
end

