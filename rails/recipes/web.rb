require_recipe "rails::app_dependencies"

if node[:active_applications]

  node[:active_applications].each do |app, conf|
    full_name = "#{app}_#{conf[:env]}"
    filename = "#{conf[:env]}_web.conf"
    path = "/u/apps/#{app}/current/config/#{system_web_server}/#{filename}"
    app_name = conf[:app_name] || app
    
    nginx_site do
      config_path path
      only_if { File.exists?("/etc/nginx/sites-available/#{full_name}") }
    end
    
    logrotate full_name do
      files "/u/apps/#{app}/current/log/*.log"
      frequency "daily"
      rotate_count 14
      compress true
      restart_command "/etc/init.d/nginx reload > /dev/null"
    end
  end
else
  Chef::Log.info "Add an :active_applications attribute to configure this node's apps"
end