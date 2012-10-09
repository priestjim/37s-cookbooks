require_recipe "nginx"
require_recipe "rails::app_dependencies"
require_recipe "unicorn"
require_recipe "bluepill"

node[:active_applications].each do |name, conf|

  app = search(:apps, "id:#{name}").first
  app_name = conf[:app_name] || name
  app_root = "/u/apps/#{app_name}"
  
  Chef::Log.info "Setting up Rails app #{name}"

  full_name = "#{app_name}_#{conf[:env]}"
  filename = "#{filename}_#{conf[:env]}.conf"

  template "/etc/nginx/sites-available/#{full_name}" do
    source "app_nginx.conf.erb"
    variables :full_name => full_name, :app => app, :conf => conf, :app_name => app_name
  end

  bluepill_monitor full_name do
    if app[:use_bundler] && app[:use_bundler] == true
      source "bluepill_unicorn_bundler.conf.erb"
    else
      source "bluepill_unicorn.conf.erb"
    end
    app_root "#{app_root}/current"
    preload app[:preload] || true
    env conf[:env]
    interval 30
    user "app"
    group "app"
    memory_limit app[:memory_limit] || 300 # megabytes
    cpu_limit 50 # percent
  end

  nginx_site full_name

  logrotate full_name do
    files "/u/apps/#{app_name}/current/log/*.log"
    frequency "daily"
    rotate_count 14
    compress true
    restart_command "/etc/init.d/nginx reload > /dev/null"
  end
end
