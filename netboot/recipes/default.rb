package "dnsmasq"
package "atftp"

netboot_nodes = search(:node, "(netboot:mac OR nfsroot:initial_ip)")

service "dnsmasq" do
  name "dnsmasq"
  supports :restart => true, :reload => false
  action :enable
end

directory "/tftpboot" do
  action :create
end

remote_file "/tftpboot/netboot.tar.gz" do
  source "http://mirrors.servercentral.net/ubuntu/dists/karmic/main/installer-amd64/current/images/netboot/netboot.tar.gz"
  not_if { File.exists?("/tftpboot/netboot.tar.gz")}
end

execute "extract netboot tar" do
  cwd "/tftpboot"
  command "tar zxf netboot.tar.gz"
end

bash "chown" do
  code "chown -R nobody: /tftpboot"
end

template "dnsmasq.conf" do
  path "/etc/dnsmasq.conf"
  source "dnsmasq.conf.erb"
  owner "root"
  group "root"
  variables(:servers => netboot_nodes)
  mode 0644
  notifies :restart, resources(:service => "dnsmasq")
end

cookbook_file "/tftpboot/ubuntu-installer/amd64/boot-screens/37menu.cfg"  do
  source "37menu.cfg"
  mode 0755
  owner "nobody"
  group "nogroup"
end

cookbook_file "/tftpboot/ubuntu-installer/amd64/boot-screens/menu.cfg"  do
  source "menu.cfg"
  mode 0755
  owner "nobody"
  group "nogroup"
end

cookbook_file "/tftpboot/ubuntu-installer/amd64/boot-screens/splash.png"  do
  source "splash.png"
  mode 0755
  owner "nobody"
  group "nogroup"
end

cookbook_file "/var/www/nginx-default/client.rb"  do
  source "client.rb"
  mode 0755
  owner "nobody"
  group "nogroup"
end

execute "rm"  do
  command "rm -f /tftpboot/pxelinux.cfg/01-*"
  ignore_failure true
end

execute "rm"  do
  command "rm -f /var/www/nginx-default/01-*.sh"
  ignore_failure true
end

execute "rm"  do
  command "rm -f /var/www/nginx-default/01-*.cfg"
  ignore_failure true
end

link "/var/www/nginx-default/ruby-enterprise_1.8.7-2010.01_amd64.deb" do
  to "/home/system/pkg/debs/ruby-enterprise_1.8.7-2010.01_amd64.deb"
end

netboot_nodes.each do |server|
  if server[:uptime] == nil || (server[:nfsroot] && server[:nfsroot][:initial_ip])
    filename = "01-" + server[:netboot][:mac].downcase.gsub(":", "-")

    template "/var/www/nginx-default/" + filename + ".cfg" do
      path "/var/www/nginx-default/" + filename + ".cfg"
      source "preseed.cfg.erb"
      variables(:key => server.name, :script => filename + ".sh", :server => server[:netboot])
      owner "root"
      group "root"
      mode 0644
      not_if { server[:nfsroot] && server[:nfsroot][:initial_ip] }
    end

    template "/var/www/nginx-default/" + filename + ".sh" do
      path "/var/www/nginx-default/" + filename + ".sh"
      source "post_install_script.sh.erb"
      variables(:key => server.name, :server => server[:netboot], :script => filename + ".sh", :filename => filename)
      owner "root"
      group "root"
      mode 0644
      not_if { server[:nfsroot] && server[:nfsroot][:initial_ip] }
    end

    template filename do
      path "/tftpboot/pxelinux.cfg/" + filename
      source ( server[:nfsroot] && server[:nfsroot][:initial_ip] ) ? "pxelinux-nfsroot.cfg.erb" : "pxelinux-default.cfg.erb"
      variables(:key => server.name, :filename => filename + ".cfg", :server => server)
      owner "root"
      group "root"
      mode 0644
    end
    
    execute "generate-client.pem"  do
      command "knife client create #{server[:fqdn]} -f /var/www/nginx-default/#{filename}.pem -u chef-validator -k /etc/chef/validation.pem -n -s https://chef/"
      not_if { File.exist?("/var/www/nginx-default/#{filename}.pem") || ( server[:nfsroot] && server[:nfsroot][:initial_ip] )}
    end
  end
end
