package "ia32-libs"

cookbook_file "/tmp/racadm.tar.gz" do
  source "racadm.tar.gz"
end

execute "untar"  do
  command "/bin/tar -C / -zvxf /tmp/racadm.tar.gz"
  not_if { File.exists?("/usr/sbin/racadm")}
end

remote_file "/tmp/libstdc++5_3.3.6-17ubuntu1_i386.deb" do
  source "http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-3.3/libstdc++5_3.3.6-17ubuntu1_i386.deb"
  not_if { File.exists?("/tmp/libstdc++5_3.3.6-17ubuntu1_i386.deb")}
end

dpkg_package "libstdc++5_3.3.6-17ubuntu1" do
  source "/tmp/libstdc++5_3.3.6-17ubuntu1_i386.deb"
  not_if "dpkg -s libstdc++5 | grep 'Version: 1:3.3.6-17ubuntu1'"
  options "--force-architecture"
end

unless File.exist?("/etc/init/ttyS1.conf")
  cookbook_file "/etc/init/ttyS1.conf" do
    source "ttyS1.conf"
  end
  
  cookbook_file "/etc/init/tty0.conf" do
    source "tty0.conf"
  end
  
  execute "start virtual console" do
    command "start tty0"
  end
  
  execute "start serial console" do
    command "start ttyS1"
  end
  
  execute "updategrub"  do
    command "update-grub"
    action :nothing
  end
  
  cookbook_file "/etc/default/grub" do
    source "grub"
    notifies :run, resources(:execute => "updategrub")
  end
end

unless File.exist?("/etc/init/tty0.conf")
  cookbook_file "/etc/init/tty0.conf" do
    source "tty0.conf"
  end
  
  execute "start virtual console" do
    command "start tty0"
  end
end