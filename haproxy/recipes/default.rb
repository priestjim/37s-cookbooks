package "haproxy" do
  action :install
end

include_recipe "ganglia::client"
include_recipe "nginx"

directory "/etc/haproxy" do
  action :create
  owner "root"
  group "root"
  mode 0755
end

directory "/var/log/haproxy" do
  action :create
  owner node[:haproxy][:user]
  group node[:haproxy][:user]
  mode 0750
end

directory "/var/run/haproxy" do
  action :create
  owner node[:haproxy][:user]
  group node[:haproxy][:user]
  mode 0750
end

cookbook_file "/etc/sysctl.d/20-ip-nonlocal-bind.conf" do
  source "20-ip-nonlocal-bind.conf"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/haproxy/500.http"

instances = {}

search(:apps) do |app|
  next unless app[:environments] && node[:active_applications][app['id']]
  app[:environments].keys.each do |env|
    next unless node[:active_applications][app['id'].to_s]['env'] == env
    app_nodes = []
    search(:node, "role:#{app['id']}-app OR (role:staging AND active_applications:#{app['id']})") do |app_node|
      next if app_node[:hostname].match(/cron|^bc-intl/) # super hacky
      app_nodes << [app_node[:hostname], app_node[:ipaddress]] if app_node[:active_applications][app['id']][:env] == env
    end
    instances["#{app['id']}_#{env}"] = {
      :admin_subdomains => app[:admin_subdomains],
      :ssl_vhosts => app[:environments][env.to_s][:ssl_vhosts],
      :maxconn => app[:environments][env.to_s]["worker_count"],
      :proxy_vip_octet => app[:proxy_vip_octet],
      :proxy_acls => app[:proxy_acls] || [],
      :proxy_backends => app[:proxy_backends] || [],
      :frontends => {
        "#{app['id']}_#{env}" => {
          :backends => {
            "app_hosts" => {
              :servers => app_nodes
            }
          }
        }
      }
    }
  end
end

instances.each do |name, config|
  template "/etc/init.d/haproxy_#{name}" do
    source "haproxy.init.erb"
    variables(:name => name)
    owner "root"
    group "root"
    mode 0755
  end
  
  service "haproxy_#{name}" do
    pattern "haproxy.*#{name}"
    supports [ :start, :stop, :restart, :reload ]
    action [ :enable ]
  end

  template "/etc/haproxy/#{name}.cfg" do
    source "haproxy.cfg.erb"
    variables(:name => name, :config => config)
    owner node[:haproxy][:user]
    group node[:haproxy][:group]
    mode 0640
    notifies :reload, resources(:service => "haproxy_#{name}")
  end
  
  (config[:ssl_vhosts] || {}).each do |domain, vhost_vip_octet|
    vhost_name = domain.gsub(/^\*\./, '').gsub(/\./, '_')
    ssl_certificate domain
    
    template "/etc/nginx/sites-enabled/#{name}-#{vhost_name}_ssl" do
      source "nginx-ssl.cfg.erb"
      variables(
        :proxy_vip => "#{node[:proxy][:vip_prefix]}.#{config[:proxy_vip_octet]}",
        :vhost_vip => "#{node[:proxy][:vip_prefix]}.#{vhost_vip_octet}",
        :certificate => domain =~ /\*\.(.+)/ ? "#{$1}_wildcard" : domain
      )
    end

    nginx_site "#{name}_ssl"
  end
  
  if node[:ganglia] && node[:ganglia][:cluster_name] == "Proxy"
    cron "gather ganglia haproxy statistics for #{name}" do
      command "/usr/local/bin/ganglia_haproxy_stats.rb -p /var/run/haproxy/#{name}.stats"
      minute "*"
      user "ganglia"
    end
  end
end
