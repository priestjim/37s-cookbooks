include_recipe "ruby"
include_recipe "runit"

gem_package "xmpp4r" do
  version "0.5"
end

gem_package "god" do
  version node[:god][:version]
end

directory "/etc/god/conf.d" do
  recursive true
  owner "root"
  group "root"
  mode 0755
end

file "/etc/god/master.god" do
  action :create
end

runit_service "god"

template "/etc/god/master.god" do
  source "master.god.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "god")
end