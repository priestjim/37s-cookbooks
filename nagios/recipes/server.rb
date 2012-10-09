require_recipe "nginx"
require_recipe "fcgiwrap"
require_recipe  "runit"
include_recipe "users"

package "nagios3"
package "nagios-nrpe-plugin"
package 'spawn-fcgi'
package 'libclass-dbi-perl'
package 'libnet-dns-perl'

# required for Solr plugin
gem_package "xml-simple"
gem_package "choice"

gem_package "tinder"
gem_package "twilio"
gem_package "xmpp4r-simple"
gem_package "twiliolib"
gem_package "clickatell"

user "nagios" do
  action :manage
  home "/etc/nagios3"
  shell "/bin/bash"
end

execute "copy distribution init.d script" do
  command "mv /etc/init.d/nagios3 /etc/init.d/nagios3.dist"
  creates "/etc/init.d/nagios3.dist"
end

directory "/etc/nagios3/.ssh" do
  mode 0700
  owner "nagios"
  group "nagios"
end

htpasswd_file "/etc/nagios3/htpasswd.users" do
  owner "nagios"
  group "www-data"
  mode 0640
end

directory "/var/lib/nagios3" do
  mode 0755
end

directory "/var/lib/nagios3/rw" do
  group "www-data"
  mode 02775
end

link "/bin/mail" do
  to "/usr/bin/mailx"
end

runit_service "nagios3"

notifiers = search(:credentials, "id:notifiers").first
sysadmin = search(:credentials, "id:sysadmin").first
campfire = search(:credentials, "id:campfire").first
sysadmin_users = search(:users, "groups:admin")

nagios_conf "nagios" do
  config_subdir false
  variables({:sysadmin => sysadmin})
end

directory "#{node[:nagios][:root]}/dist" do
  owner "nagios"
  group "nagios"
  mode 0755
end

%w(templates contacts commands).each do |dir|
  directory "#{node[:nagios][:root]}/conf.d/#{dir}" do
    owner "nagios"
    group "nagios"
    mode 0755
    
  end
end

execute "archive default nagios object definitions" do
  command "mv #{node[:nagios][:root]}/conf.d/*_nagios*.cfg #{node[:nagios][:root]}/dist"
  not_if { Dir.glob(node[:nagios][:root] + "/conf.d/*_nagios*.cfg").empty? }
end

remote_directory node[:nagios][:notifiers_dir] do
  source "notifiers"
  files_backup 5
  files_owner "nagios"
  files_group "nagios"
  files_mode 0755
  owner "nagios"
  group "nagios"
  mode 0755
end

role_list = begin
              Chef::Role.list()
            rescue => e
              Chef::Log.error("#{e}\n#{e.backtrace.join("\n")}")
              {}
            end

device_types = [ "apc_pdu", "fortigate_firewall", "cisco_switch", "isilon_storage", "rac", "osx_server"]
devices = search(:devices, "*:*")
cisco_switches = search(:devices, "type:cisco_switch")
fortigate_firewalls = search(:devices, "type:fortigate_firewall")
apc_pdus = search(:devices, "type:apc_pdu")
isilon_storage_clusters = search(:devices, "type:isilon_storage")
snmp = search(:credentials, "id:snmp").first
other_hosts = search(:nagios_hosts, "*:*")
no_ping_devices = search(:devices, "disable_ping:true")
proxy_servers = search(:node, "role:proxy")
free_disk_disable_servers = search(:node, "nagios_free_disk_enable:false")
free_memory_disable_servers = search(:node, "nagios_free_memory_enable:false")
load_disable_servers = search(:node, "nagios_load_enable:false")
pager_duty_credentials = search(:credentials, "id:pager_duty").first

nagios_conf "hostgroups" do
  variables({:roles => role_list, :device_types => device_types})
end

nodes = search(:node, "*:*")

nagios_conf "hostgroups" do
  variables({
    :roles => role_list.delete_if {|role, _| !nodes.detect{|n| n.run_list.roles.include?(role) }},
    :device_types => device_types
    })
end

nagios_conf "hosts" do
  variables({:hosts => nodes, :devices => devices, :other_hosts => other_hosts})
end

nagios_conf "contacts" do
  variables({:sysadmins => sysadmin_users, :campfire => campfire})
end

nagios_conf "service_templates"
nagios_conf "templates"

nagios_conf "commands" do
  variables({:notifiers => notifiers})
  
end

nagios_conf "timeperiods"

nagios_conf "cgi" do
  config_subdir false
end

nagios_conf "pagerduty_nagios" do
  variables(:credentials => pager_duty_credentials)
end

proxy_instances = []
proxy_servers.each do |proxy_server|
  proxy_server[:active_applications].each do |app_name, active_application|
    app = search(:apps, "id:#{app_name}").first
    proxy_instances << [proxy_server[:hostname], proxy_server[:proxy][:vip_prefix], app[:proxy_vip_octet], app_name] if proxy_server[:proxy] && proxy_server[:proxy][:vip_prefix] && app[:proxy_vip_octet]
  end
end

nagios_conf "services" do
  variables(
    :cisco_switches => cisco_switches, 
    :fortigate_firewalls => fortigate_firewalls,
    :apc_pdus => apc_pdus,
    :isilon_storage_clusters => isilon_storage_clusters,
    :community => snmp['community'],
    :devices => devices,
    :nodes => nodes,
    :other_hosts => other_hosts,
    :no_ping_devices => no_ping_devices,
    :proxy_instances => proxy_instances,
    :free_disk_disable_servers => free_disk_disable_servers,
    :free_memory_disable_servers => free_memory_disable_servers,
    :load_disable_servers => free_memory_disable_servers
    )
end

template "/etc/nagios3/nginx.conf" do
  source "nginx.conf.erb"
end

# install the wildcard cert for this domain
ssl_certificate "*.#{node[:domain]}"

link "/usr/share/nagios3/htdocs/stylesheets" do
  to "/etc/nagios3/stylesheets"
end

nginx_site "nagios" do
  config_path "/etc/nagios3/nginx.conf"
end

bot_data = search(:credentials, "id:jabber").first

runit_service "nagios-bot" do
  options :bot_data => bot_data
end
