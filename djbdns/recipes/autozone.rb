# This recipe will generate a zone file from the chef server's node list. Requires chef-client
# It also automatically generates an authoritative zone record for the current domain and an A record for 'chef' pointing to the current server

include_recipe "djbdns::internal_server"

hosts = []
search(:node, "*:*") {|n| hosts << n }

template "/etc/tinydns-internal/root/zones/chef-server.zone" do
  source "tinydns-internal-data.erb"
  mode 644
  backup 0
  variables(:hosts => hosts,
            :chef_server_ip => node[:chef_server_ip] || node[:ipaddress],
            :gem_mirror_ip => node[:gem_mirror_ip] || node[:ipaddress],
            :dist_ip => node[:dist_ip] || node[:ipaddress],
            :apt_mirror_ip => node[:apt_mirror_ip] || node[:ipaddress]
  )
  notifies :run, resources("execute[build-tinydns-internal-data]")
  notifies :restart, resources(:service => "public-dnscache")
end
