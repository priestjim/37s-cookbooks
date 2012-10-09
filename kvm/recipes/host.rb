
package 'libcap2-bin'
package 'bridge-utils'
package 'kvm'
package 'libvirt-bin'
package 'libvirt-dev'
package 'ubuntu-vm-builder'

gem_package 'hpricot'

# Setup vmbuilder templates and post install scripts.
directory "/usr/local/share/kvm" do
  owner "root"
  group "libvirtd"
  mode 0750
end

%w(files scripts templates).each do |type|
  remote_directory "/usr/local/share/kvm/#{type}" do
    source type
    owner "root"
    group "libvirtd"
    mode 0755
    files_mode 0755
    files_backup false
  end
end

template "/usr/local/share/kvm/scripts/bootstrap-chef.sh" do
  source "bootstrap-chef.sh.erb"
  owner "root"
  group "libvirtd"
  mode 0755
  backup false
end

# Grant special powers to QEMU
file "/usr/bin/qemu-system-x86_64" do
  owner "root"
  group "admin"
  mode 04750
end

# Setup network bridging
service "networking"
cookbook_file "/etc/network/interfaces" do
  source "interfaces"
  notifies(:restart, resources(:service => "networking"))  
end

# Install the Ruby libvirt gem
libvirt_gem = "ruby-libvirt-0.1.0.gem"
execute "install ruby-libvirt gem" do
  cwd "/tmp"
  command "wget #{node[:pkg_url]}/gems/#{libvirt_gem} && gem install #{libvirt_gem} --no-rdoc --no-ri"
  not_if "gem list ruby-libvirt | grep 0.1.0"
end

search(:slices, "host:#{node[:hostname]}").each do |slice|
  defaults ||= search(:slices, "id:default").first
  slice = defaults.merge(slice)

  # Install VMs
  virtual_machine slice[:id] do
    path slice[:path]
    vcpus slice[:vcpus]
    memory slice[:memory]
    run_list slice[:run_list]

    suite slice[:suite]
    flavor slice[:flavor]
    arch slice[:arch]
    root_size slice[:root_size]
    swap_size slice[:swap_size]

    external_ip slice[:external_ip]
    storage_ip slice[:storage_ip]
    root_password slice[:root_password]
  end
end
