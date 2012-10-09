include_recipe "djbdns"

execute "public_cache_update" do
  cwd "/etc/public-dnscache"
  command "/usr/bin/dnsip `/usr/bin/dnsqr ns . | awk '/answer:/ { print \$5 ; }' | sort` > root/servers/@"
  action :nothing
end

execute "/usr/bin/dnscache-conf dnscache dnslog /etc/public-dnscache #{node[:djbdns][:public_dnscache_ipaddress]}" do
  only_if "/usr/bin/test ! -d /etc/public-dnscache"
  notifies :run, resources("execute[public_cache_update]")
end

template "/etc/public-dnscache/run" do
  source "sv-cache-run.erb"
  mode 0755
end

template "/etc/public-dnscache/log/run" do
  source "sv-cache-log-run.erb"
  mode 0755
end

node[:djbdns][:public_dnscache_allowed_networks].each do |net|
  file "/etc/public-dnscache/root/ip/#{net}" do
    mode 0644
  end
end

template "/etc/public-dnscache/root/servers/#{node[:domain]}" do
  source "dnscache-servers.erb"
  mode 0644
end

search(:internal_zones, "*:*").each do |zone|
  template "/etc/public-dnscache/root/servers/#{zone[:domain]}" do
    source "dnscache-servers.erb"
    mode 0644
  end
end

node[:djbdns][:ptr_networks].each do |network|
  template "/etc/public-dnscache/root/servers/#{network}.in-addr.arpa" do
    source "dnscache-servers.erb"
    mode 0644
  end
end

link "#{node[:runit_service_dir]}/public-dnscache" do
  to "/etc/public-dnscache"
end

link "/etc/init.d/public-dnscache" do
  to node[:runit_sv_bin]
end

service "public-dnscache" do
  supports :restart => true, :status => true
end
