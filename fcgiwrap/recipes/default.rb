require_recipe "bluepill"

package "libfcgi-dev"
package "autoconf"

cookbook_file "/tmp/fcgiwrap.tar.gz" do
  not_if { File.exists?("/usr/local/sbin/fcgiwrap") }
end

execute "unpack fcgiwrap" do
  cwd "/tmp"
  command "tar xvzf /tmp/fcgiwrap.tar.gz"
  only_if { File.exists?("/tmp/fcgiwrap.tar.gz")}
end

execute "make and install fcgiwrap" do
  command "autoconf && ./configure && make && make install"
  creates "/usr/local/sbin/fcgiwrap"
end

bluepill_monitor "fcgiwrap" do
  cookbook "fcgiwrap"
  source "bluepill.conf.erb"
  user node[:fcgiwrap][:user]
  group node[:fcgiwrap][:group]
  memory_limit 250 # megabytes
  pid_file node[:fcgiwrap][:pid_file]
  port node[:fcgiwrap][:port]
end
