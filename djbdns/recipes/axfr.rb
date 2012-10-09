include_recipe "djbdns"

user "axfrdns" do
  uid 9996
  gid "nogroup"
  shell "/bin/false"
  home "/home/axfrdns"
end

execute "/usr/bin/axfrdns-conf axfrdns dnslog /etc/axfrdns /etc/tinydns #{node[:djbdns][:axfrdns_ipaddress]}" do
  only_if "/usr/bin/test ! -d /etc/axfrdns"
end

template "/etc/axfrdns/run" do
  source "sv-axfr-run.erb"
  mode 0755
end

template "/etc/axfrdns/log/run" do
  source "sv-axfr-log-run.erb"
  mode 0755
end

link "#{node[:runit_service_dir]}/axfrdns" do
  to "/etc/axfrdns"
end

link "/etc/init.d/axfrdns" do
  to node[:runit_sv_bin]
end