require_recipe "syslog"
require_recipe "logsort"

apps = search(:apps)

#active_apps = node[:syslog][:active_applications].collect {|a| apps.detect {|app| app[:id].to_s == a.to_s }}

template "/etc/syslog-ng/syslog-ng.conf" do
  source "syslog-ng-server.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "syslog-ng")
  variables(:apps => apps)
end

directory node[:syslog_ng][:root] do
  owner "root"
  group "admin"
end

directory node[:syslog_ng][:root] + "/syslog" do
  owner "root"
  group "app"
  mode 0750
  recursive true
end

logrotate "syslog-remote" do
  restart_command "/etc/init.d/syslog-ng reload 2>&1 || true"
  files ['/u/logs/syslog/messages', "/u/logs/syslog/secure", "/u/logs/syslog/maillog", "/u/logs/syslog/cron", "/u/logs/syslog/bluepill", "/u/logs/syslog/boot.log"]
end

apps.each do |app|
  directory node[:syslog_ng][:root] + "/#{app[:id]}" do
    owner "app"
    group "app"
    mode 0750
  end
  
  if app[:syslog_files] && app[:syslog_files][:logsort]
    cron "logsort log rotation: #{app[:id]}" do
      command "find /u/logs/#{app[:id]} -maxdepth 1 -type d -mtime +4 -exec rm -rf {} \\;"
      hour "10"
      minute "0"
    end
  end
end

logrotate "applications" do
  restart_command "/etc/init.d/syslog-ng reload 2>&1 || true"
  files apps.collect {|a| node[:syslog_ng][:root] + "/#{a[:id]}/*.log" }
  frequency "daily"
end
