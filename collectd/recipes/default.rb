package "collectd"

service "collectd" do
  supports :restart => true, :status => true
end

%w(collectd collection thresholds).each do |file|
  template "/etc/collectd/#{file}.conf" do
    source "#{file}.conf.erb"
    owner "root"
    group "root"
    mode "644"
    notifies :restart, resources(:service => "collectd")
  end
end

