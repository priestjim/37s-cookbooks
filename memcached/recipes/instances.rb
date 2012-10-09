require_recipe "memcached"

service "memcached" do
  action [:stop, :disable]
end

if node[:memcached][:instances]
  node[:memcached][:instances].each do |name, instance|
    memcached_config = { "max_memory" => node[:memcached][:max_memory],
                         "port" => node[:memcached][:port], "user" => node[:memcached][:user],
                         "max_connections" => node[:memcached][:max_connections] }.merge(instance)

    bluepill_monitor "memcached_#{name}" do 
      cookbook "memcached"
      source "bluepill.conf.erb"
      pid_path "/var/run/memcached_#{name}.pid"
      user "root"
      group "root"
      config memcached_config
    end  
  end
end
