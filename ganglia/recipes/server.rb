require_recipe "nginx"
include_recipe "users"
include_recipe "nginx"
include_recipe "bluepill"

package "libfcgi-dev"
package 'spawn-fcgi'
package "ganglia-webfrontend"
package "gmetad"
package "php5-cgi"
package "php5-gd"

template "/etc/ganglia/nginx.conf" do
  source "nginx.conf.erb"
  backup false
  owner "root"
  group "www-data"
  mode 0640
end

nginx_site "ganglia" do
  config_path "/etc/ganglia/nginx.conf"
end

service "gmetad" do
  enabled true
end

cluster_nodes = {}
search(:node, '*:*') do |node|
  next unless node['ganglia'] && node['ganglia']['cluster_name']
  cluster_nodes[node['ganglia']['cluster_name']] ||= []
  cluster_nodes[node['ganglia']['cluster_name']] << node['fqdn'].split('.').first
end

template "/etc/ganglia/gmetad.conf" do
  source "gmetad.conf.erb"
  backup false
  owner "ganglia"
  group "ganglia"
  mode 0644
  variables(:cluster_nodes => cluster_nodes, :clusters => search(:ganglia_clusters, "*:*"))
  notifies :restart, resources(:service => "gmetad")
end

directory "/var/lib/ganglia/rrds" do
  owner "ganglia"
  group "ganglia"
end

bluepill_monitor "ganglia-php-cgi" do
  cookbook "ganglia"
  source "bluepill.conf.erb"
  user "www-data"
  group "www-data"
  memory_limit 250 # megabytes
  pid_file "/var/run/php-cgi.pid"
  port 47001
end

cookbook_file "/usr/share/ganglia-webfrontend/host_view.php" do
  source "host_view.php"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/usr/share/ganglia-webfrontend/templates/default/host_view.tpl" do
  source "host_view.tpl"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/usr/share/ganglia-webfrontend/conf.php" do
  source "conf.php"
  owner "root"
  group "root"
  mode "0644"
end
