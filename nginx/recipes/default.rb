nginx_filename = ["nginx", node[:nginx][:version], node[:nginx][:architecture]].join("_")+".deb"

package "libperl5.10"
package "libgd2-noxpm"
package "libxslt1.1"
package "libgeoip1"

dpkg_package "nginx" do
  source "/home/system/pkg/debs/#{nginx_filename}"
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

cookbook_file "#{node[:nginx][:dir]}/mime.types"

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, resources(:service => "nginx")
end

directory "/etc/nginx/helpers"

# helpers to be included in your vhosts
node[:nginx][:helpers].each do |h|
  template "/etc/nginx/helpers/#{h}.conf" do
    notifies :reload, resources(:service => "nginx")
  end
end

# server-wide defaults, automatically loaded
node[:nginx][:extras].each do |ex|
  template "/etc/nginx/conf.d/#{ex}.conf" do
    notifies :reload, resources(:service => "nginx")
  end
end  

service "nginx" do
  action [ :enable, :start ]
end

nginx_site "default" do
  enable false
end