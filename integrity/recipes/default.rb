gem_package "integrity" do
  source "http://localgems"
end

# uses bundler now
# gem_package "do_sqlite3"
# gem_package "do_mysql"
# gem_package "mocha"
# gem_package "rcov"
# gem_package "ruby-debug"
# gem_package "quietbacktrace"
# gem_package "tinder"

if node[:integrity][:projects]
  node[:integrity][:projects].each do |app|
    if node[:applications][app][:gems]
      node[:applications][app][:gems].each do |g|
        if g.is_a? Array
          gem_package g.first do
            version g.last
          end
        else
          gem_package g
        end
      end
    end
    
    if node[:applications][app][:packages]
      node[:applications][app][:packages].each do |package_name|
        package package_name
      end      
    end
    
    if node[:applications][app][:symlinks]
      node[:applications][app][:symlinks].each do |target, source|
        link target do
          to source
        end
      end
    end
  end
end

execute "setup_integrity" do
  command "integrity install #{node[:integrity][:path]} --passenger"
  user "app"
  group "app"
  not_if "test -e /u/apps/integrity"
end

template "#{node[:integrity][:path]}/config.ru" do
  source "config.ru.erb"
  owner "app"
  group "app"
  mode 0644
end

# template "#{node[:integrity][:path]}/config.yml" do
#   source "config.yml.erb"
#   owner "app"
#   group "app"
#   mode 0644
# end

template "#{node[:integrity][:path]}/vhost.conf" do
  source "vhost.conf.erb"
  owner "app"
  group "app"
  mode 0644
end

# remote_file "#{node[:integrity][:path]}/integrity_build.rb" do
#   source "integrity_build.rb"
#   owner "app"
#   group "app"
#   mode 0700
# end
# 
# cron "integrity_build" do
#   user "app"
#   minute "*/10"
#   command "/usr/local/bin/ruby #{node[:integrity][:path]}/integrity_build.rb"
#   only_if { File.exist?(File.join(node[:integrity][:path], "integrity_build.rb")) }
# end

apache_site "integrity" do
  config_path "#{node[:integrity][:path]}/vhost.conf"
  not_if { File.exists?("/etc/apache2/sites-enabled/integrity") }
end

logrotate "integrity" do
  files "#{node[:integrity][:path]}/log/*.log"
  frequency "weekly"
  restart_command "/etc/init.d/apache2 reload > /dev/null"
end
