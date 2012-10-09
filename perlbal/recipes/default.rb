require_recipe "mogilefs"
require_recipe "bluepill"

directory "#{node[:perlbal][:config_path]}" do
  owner "root"
  group "root"
end

bluepill_monitor 'perlbal'

template "#{node[:perlbal][:config_path]}/perlbal.conf" do
  source "perlbal.conf.erb"
  owner "app"
  mode 0600
  notifies :run, resources("execute[restart-bluepill-perlbal]")
end

