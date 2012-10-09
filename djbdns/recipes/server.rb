include_recipe "djbdns"

execute "/usr/bin/tinydns-conf tinydns dnslog /etc/tinydns #{node[:djbdns][:tinydns_ipaddress]}" do
  only_if "/usr/bin/test ! -d /etc/tinydns"
end

execute "build-tinydns-data" do
  cwd "/etc/tinydns/root"
  command "make"
  action :nothing
end

template "/etc/tinydns/root/data" do
  source "tinydns-data.erb"
  mode 644
  notifies :run, resources("execute[build-tinydns-data]")
end

template "/etc/tinydns/run" do
  source "sv-server-run.erb"
  mode 0755
end

template "/etc/tinydns/log/run" do
  source "sv-server-log-run.erb"
  mode 0755
end

link "#{node[:runit_service_dir]}/tinydns" do
  to "/etc/tinydns"
end

link "/etc/init.d/tinydns" do
  to node[:runit_sv_bin]
end
