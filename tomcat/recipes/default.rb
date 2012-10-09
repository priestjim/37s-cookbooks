require_recipe "java"

return unless ["ubuntu", "debian"].include?(node[:platform])

package "tomcat6"

service "tomcat6" do
  supports [ :status, :restart ]
end

template "/etc/default/tomcat6" do
  source "default.tomcat6.erb"
  owner "root"
  group "root"
  mode 0644
  
  notifies :restart, resources(:service => "tomcat6")
end

template "/etc/tomcat6/server.xml" do
  source "server.xml.erb"
  owner "app"
  group "admin"
  mode 0644
  
  notifies :restart, resources(:service => "tomcat6")
end

execute "fix_permissions" do
  command "chown -R #{node[:tomcat][:user]}:admin /etc/tomcat6 /var/log/tomcat6 /var/lib/tomcat6 /var/cache/tomcat6 && touch /etc/tomcat6/perms.ok"
  creates "/etc/tomcat6/perms.ok"
end  
