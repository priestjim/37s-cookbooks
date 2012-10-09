require_recipe "nginx"
require_recipe "rails::app_dependencies"

apps = search(:apps)

apps.each do |app|
  directory "/u/apps/#{app[:id]}/shared/log" do
    recursive true
    group "www-data"
    mode 0775
  end
end

template "/etc/nginx/sites-available/assets" do
  source "assets.conf.erb"
  variables :apps => apps
end

nginx_site "assets"

logrotate "nginx_logs" do
  files "/u/apps/*/current/log/*.log"
  frequency "daily"
  rotate_count 14
  compress true
  restart_command "/etc/init.d/nginx reload > /dev/null"
end