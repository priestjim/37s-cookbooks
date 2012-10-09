remote_file "/tmp/mogilefs.tar.bz2" do
  source node[:mogilefs][:pkg]
  not_if "test -e #{node[:mogilefs][:path]}"
end

execute "install_mogilefs" do
  command "tar -C /u/apps -xpjf /tmp/mogilefs.tar.bz2 && rm -f /tmp/mogilefs.tar.bz2"
  only_if "test -e /tmp/mogilefs.tar.bz2"
end

template "#{node[:mogilefs][:path]}/etc/mogilefs.conf" do
  source "mogilefs.conf.erb"
  owner "root"
  group "app"
  mode 0644
end

template "/etc/profile.d/mogilefs.sh" do
  source "mogilefs.sh.erb"
  owner "root"
  mode 0644
end

link "/etc/mogilefs" do
  to "#{node[:mogilefs][:path]}/etc"
end
