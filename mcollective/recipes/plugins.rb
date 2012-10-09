#
# Cookbook Name:: mcollective
# Recipe:: plugins
#
# Copyright 2010, 37signals
#
# All rights reserved - Do Not Redistribute
#


include_recipe "bluepill" 

gem_package "stomp"

%w(mcollective-common mcollective).each do |pkg|
  dpkg_package pkg do
    source "#{node[:system_root]}/pkg/mcollective/#{pkg}_#{node.mcollective[:version]}_all.deb"
  end
end

server = data_bag_item('mcollective', 'server')
client = data_bag_item('mcollective', 'client')
config = data_bag_item('mcollective', 'general')

template "/etc/mcollective/server.cfg" do
  source "server.cfg.erb"
  owner "root"
  group "root"
  mode 00644
  variables(:config => config,
            :queue_user => server['user'],
            :queue_password => server['password'])
end

bluepill_monitor "mcollectived" do
  cookbook "mcollective"
  source "bluepill.conf.erb"
  user "root"
  group "root"
  memory_limit 250 # megabytes
  pid_file "/var/run/mcollectived.pid"
end
