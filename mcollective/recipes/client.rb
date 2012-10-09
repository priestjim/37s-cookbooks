#
# Cookbook Name:: mcollective
# Recipe:: client
#
# Copyright 2010, 37signals
#
# All rights reserved - Do Not Redistribute
#

gem_package "stomp"

%w(mcollective-common mcollective-client).each do |pkg|
  dpkg_package pkg do
    source "#{node[:system_root]}/pkg/mcollective/#{pkg}_#{node.mcollective[:version]}_all.deb"
  end
end

server = data_bag_item('mcollective', 'server')
client = data_bag_item('mcollective', 'client')
config = data_bag_item('mcollective', 'general')

template "/etc/mcollective/client.cfg" do
  source "client.cfg.erb"
  owner "root"
  group "root"
  mode 00644
  variables(:config => data_bag_item('mcollective', 'general'),
            :queue_user => data_bag_item('mcollective', 'client')['user'],
            :queue_password => data_bag_item('mcollective', 'client')['password'])
end
