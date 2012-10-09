require_recipe "nginx"
require_recipe "memcached"

template "/etc/nginx/sites-available/memcache_proxy" do
  source "memcache_proxy.conf.erb"
  notifies :restart, resources(:service => "nginx")
end