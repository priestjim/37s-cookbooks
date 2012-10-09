unless node[:platform] == "ubuntu"
  Chef::Log.warn("This recipe is only available for Ubuntu systems.")
  return
end

package "libmcrypt4"
package "libltdl7"
package "apache2-mpm-worker"
package "libapache2-mod-fcgid"
apache_module "fcgid"

bash "install_php" do
  code <<-EOC
wget #{node[:php5][:dist_url]}
tar -C /#{node[:php5][:path].split("/")[1..-2].join("/")} -xpf #{node[:php5][:tar_pkg]}
EOC
  user "root"
  cwd "/tmp"
  not_if { File.directory?(node[:php5][:path]) }
end

link "/usr/bin/php-cgi" do
  to "/usr/local/php/bin/php-cgi" 
end

template "/usr/local/php/lib/php.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode 0644
end

