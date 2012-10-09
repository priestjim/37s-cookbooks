gem_package "builder"

directory node[:rubygems][:mirror][:base_path] do
  action :create
  owner "root"
  group "root"
  mode 0755
end

directory "/etc/rubygems" do
  mode 0755
end

template "/etc/rubygems/mirror.conf" do
  source "gemmirrorrc.erb"
  mode 0644
end

cron "gem mirror nightly update" do
  command "gem mirror --config-file=/etc/rubygems/mirror.conf && find #{node[:rubygems][:mirror][:base_path]}/gems -name \"*win32*\" -delete && gem generate_index -d /u/mirrors/gems > /var/log/gem-mirror.log 2>&1"
  hour "2"
  minute "0"
end

template "/etc/rubygems/gem-mirror.vhost.conf" do
  source 'mirror-vhost.conf.erb'
  action :create
  owner "root"
  group "www-data"
  mode 0640
end

apache_site "gem-mirror" do
  config_path "/etc/rubygems/gem-mirror.vhost.conf"
end
