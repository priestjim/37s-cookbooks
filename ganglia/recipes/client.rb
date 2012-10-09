
package "ganglia-monitor"
package "bc"

service "ganglia-monitor" do
  enabled true
  running true
  pattern "gmond"
end

template "/etc/ganglia/gmond.conf" do
  source "gmond.conf.erb"
  backup false
  owner "ganglia"
  group "ganglia"
  mode 0644
  variables(:server => false,
            :cluster => {
              :name => node[:ganglia][:cluster_name],
              :port => search(:ganglia_clusters, "name:#{node[:ganglia][:cluster_name]}").first[:port]
            })
  notifies :restart, resources(:service => "ganglia-monitor")
end

cookbook_file "/usr/local/bin/ganglia_disk_stats.pl" do
  source "ganglia_disk_stats.pl"
  owner "root"
  group "root"
  mode "0755"
end

node[:filesystem].each do |device,options|
  next unless options[:mount] == "/"
  disk = device.gsub(/\/dev\//, '').gsub(/[0-9]+$/, '')
  cron "gather ganglia I/O statistics for #{disk}" do
    command "/usr/local/bin/ganglia_disk_stats.pl #{disk}"
    minute "*"
  end
end

node[:ganglia][:disks].each do |disk|
  cron "gather ganglia I/O statistics for #{disk}" do
    command "/usr/local/bin/ganglia_disk_stats.pl #{disk}"
    minute "*"
  end
end

if node[:mysql] && node[:mysql][:instances]
  node[:mysql][:instances].each do |name, instance|
    template "/usr/local/bin/ganglia-mysql-#{name}.sh" do
      source "gmetric-mysql.sh.erb"
      owner "ganglia"
      group "ganglia"
      mode "0700"
      variables(:instance => instance, :name => name, :root_password => search(:mysql, "id:#{name}").first[:root_password])
    end
    
    cron "gather ganglia MYSQL statistics for #{name}" do
      command "/usr/local/bin/ganglia-mysql-#{name}.sh"
      minute "*"
      user "ganglia"
    end
  end
end

if node[:memcached] && node[:memcached][:instances]
  node[:memcached][:instances].each do |name, instance|
    template "/usr/local/bin/ganglia-memcached-#{name}.sh" do
      source "gmetric-memcached.sh.erb"
      owner "ganglia"
      group "ganglia"
      mode "0700"
      variables(:instance => instance, :name => name)
    end
    
    cron "gather ganglia Memcache statistics for #{name}" do
      command "/usr/local/bin/ganglia-memcached-#{name}.sh"
      minute "*"
      user "ganglia"
    end
  end
end

cookbook_file "/usr/local/bin/ganglia_haproxy_stats.rb" do
  source "ganglia_haproxy_stats.rb"
  owner "ganglia"
  group "ganglia"
  mode "0755"
end
