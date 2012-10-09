require_recipe "mogilefs"
require_recipe "runit"

template "#{node[:mogilefs][:path]}/etc/mogilefsd.conf" do
  source "mogilefsd.conf.erb"
  owner "app"
  group "app"
  mode 0600
end

bluepill_monitor "mogilefsd"
#runit_service "mogilefsd"
