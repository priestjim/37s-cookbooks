require_recipe "apache2"

# Required to compile passenger
package "apache2-prefork-dev"

gem_package "passenger" do
  action :install
  version node[:passenger][:version]
end

execute "passenger_module" do
  command 'echo -en "\n\n\n\n" | passenger-install-apache2-module'
  creates node[:passenger][:module_path]
end

gem_package "SyslogLogger"

template node[:passenger][:apache_load_path] do
  source "passenger.load.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "apache2")
end

template node[:passenger][:apache_conf_path] do
  source "passenger.conf.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "apache2")
end

remote_file "/usr/local/bin/passenger_monitor" do
  source "passenger_monitor"
  mode 0755
end

cron "passenger memory monitor" do
  command "/usr/local/bin/passenger_monitor #{node[:passenger][:soft_memory_limit]} #{node[:passenger][:hard_memory_limit]}"
end

apache_module "passenger"
include_recipe "apache2::mod_deflate"
include_recipe "apache2::mod_rewrite"