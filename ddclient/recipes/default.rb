package "ddclient"

service "ddclient" do
  supports :restart => true
  action :enable
end

template "/etc/default/ddclient" do
  source "ddclient.default.erb"
  mode 0644
  owner "root"
  notifies :restart, resources(:service => "ddclient")
end

template "/etc/ddclient.conf" do
  source "ddclient.conf.erb"
  mode 0600
  owner "root"
  notifies :restart, resources(:service => "ddclient")
end

service "ddclient" do
  action :start
end