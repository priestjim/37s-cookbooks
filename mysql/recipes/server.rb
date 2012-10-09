package "xfsprogs"
package "mysql-client"

script_dir = File.join(node[:mysql][:root], "scripts").to_s

dpkg_package "xtrabackup" do
  source "#{node[:system_root]}/pkg/mysql/xtrabackup_#{node.mysql[:xtrabackup_version]}_amd64.deb"
end

if node[:mysql] && node[:mysql][:instances]
  directory script_dir do
    owner "root"
    group "root"
    mode 00700
    recursive true
  end

  node[:mysql][:instances].each do |name, instance|
    mysql_server name do
      config instance[:config]
      version instance[:version]
      perform_backups instance[:perform_backups] if instance[:perform_backups]
      backup_location instance[:backup_location] if instance[:backup_location]
    end
  end
else
  Chef::Log.warn "You included the MySQL server recipe, but didn't specify MySQL instances"
end
