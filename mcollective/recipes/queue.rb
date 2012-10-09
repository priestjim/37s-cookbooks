#
# Cookbook Name:: mcollective
# Recipe:: client
#
# Copyright 2010, 37signals
#
# All rights reserved - Do Not Redistribute
#

include_recipe "activemq"

server = data_bag_item('mcollective', 'server')
client = data_bag_item('mcollective', 'client')

template "/opt/apache-activemq-#{node[:activemq][:version]}/conf/activemq.xml" do
  source "activemq.xml.erb"
  owner node[:activemq][:owner]
  group node[:activemq][:group]
  notifies :restart, resources(:service => 'activemq')
  variables(:server => server, :client => client)
end
