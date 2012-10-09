require_recipe "maatkit"
package "tcpdump"

if node[:mysql][:instances]
  node[:mysql][:instances].each do |name, instance|
    Chef::Log.info "Checking #{name} for slaves for warming"
    next unless instance[:slaves]
    db = search(:mysql, "id:#{name}").first
    
    instance[:slaves].find_all {|sl| sl[:warm] == true && !node[:fqdn].match(/^#{sl[:host]}/) }.each do |slave|
      Chef::Log.info "Installing warmer for slave at #{slave[:host]}"
      bluepill_monitor "#{slave[:host]}_slave_warmer" do
        source "bluepill_slave_warmer.conf.erb"
        user "#{name}_ro"
        password db[:password]
        port slave[:port]
        instance name
        database "#{name}_production"
        host slave[:host]
      end
    end
  end
end
