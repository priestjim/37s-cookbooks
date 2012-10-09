default.passenger[:version] = '2.2.9'
default.passenger[:nginx][:passenger_version] = "2.9.1"
default.passenger[:nginx][:nginx_version] = "0.8.32"

default.passenger[:root_path]        = "#{node[:languages][:ruby][:gems_dir]}/gems/passenger-#{passenger[:version]}"
default.passenger[:enterprise_root_path] = "#{node[:languages][:ruby][:gems_dir]}/gems/passenger-enterprise-server-#{passenger[:nginx][:passenger_version]}"

default.passenger[:module_path]      = "#{passenger[:root_path]}/ext/apache2/mod_passenger.so"
default.passenger[:apache_load_path] = '/etc/apache2/mods-available/passenger.load'
default.passenger[:apache_conf_path] = '/etc/apache2/mods-available/passenger.conf'

default.passenger[:soft_memory_limit] = 230
default.passenger[:hard_memory_limit] = 500