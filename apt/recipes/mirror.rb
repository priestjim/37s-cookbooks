require_recipe "apt"

package "apt-mirror"

directory node[:apt][:mirror][:base_path] do
  action :create
  owner "root"
  group "root"
  mode 0755
end

%w(var skel mirror www).each do |dir|
  directory node[:apt][:mirror][:base_path]+"/#{dir}" do
    action :create
    owner "root"
    group "root"
    mode 0755
  end
end

template "/etc/apt/mirror.list" do
  source "apt-mirror.list.erb"
  mode 0644  
end

cron "apt mirror nightly update" do
  command "/usr/bin/apt-mirror >> /var/log/apt-mirror.log 2>&1"
  hour "5"
  minute "0"
  only_if  { File.exist?(node[:apt][:mirror][:base_path]+"/mirror") }
end

link node[:apt][:mirror][:base_path]+"/www/archive-ubuntu" do
  to node[:apt][:mirror][:base_path]+"/mirror/archive.ubuntu.com"
end

link node[:apt][:mirror][:base_path]+"/www/security-ubuntu" do
  to node[:apt][:mirror][:base_path]+"/mirror/security.ubuntu.com"
end

link node[:apt][:mirror][:base_path]+"/www/archive-canonical" do
  to node[:apt][:mirror][:base_path]+"/mirror/archive.canonical.com"
end

template "/etc/apt/mirror.vhost.conf" do
  source 'mirror-vhost.conf.erb'
  action :create
  owner "root"
  group "www-data"
  mode 0640
end

apache_site "apt-mirror" do
  config_path "/etc/apt/mirror.vhost.conf"
end

directory node[:apache][:sites][:dist][:document_root] do
  group "admin"
  mode 0775
end

template "/u/mirrors/dist.vhost.conf" do
  source 'dist-vhost.conf.erb'
  action :create
  owner "root"
  group "www-data"
  mode 0640
end

apache_site "dist" do
  config_path "/u/mirrors/dist.vhost.conf"
end
