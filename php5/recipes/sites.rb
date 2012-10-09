require_recipe "php5::default"

directory "/u/logs" do
  mode 0755
  owner "root"
  group "root"
end

directory "/u/logs/sites" do
  mode 0775
  owner "app"
  group "www-data"
end

logrotate "website_logs" do
  files "/u/logs/sites/*.log"
  frequency "weekly"
  restart_command "/etc/init.d/apache2 reload > /dev/null"
end

if node[:active_sites]
  node[:active_sites].each do |site, conf|

    full_name = "#{site}_#{conf[:env]}"

    apache_site full_name do
      config_path "/u/sites/#{site}/current/config/apache/#{conf[:env]}.conf"
      only_if { File.exists?("/etc/apache2/sites-available/#{full_name}") }
    end

    logrotate full_name do
      files "/u/sites/#{site}/shared/log/*.log"
      frequency "weekly"
      restart_command "/etc/init.d/apache2 reload > /dev/null"
    end
  end
else
  Chef::Log.info "Add an 'active_sites' attribute to configure this node's sites"
end
