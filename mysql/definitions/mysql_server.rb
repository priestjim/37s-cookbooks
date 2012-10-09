define :mysql_server, :options => {} do
  base_dir = "#{node[:mysql][:root]}/#{params[:name]}"
  mysql_dir = "#{node[:mysql][:root]}/server/#{params[:version]}"
  params[:config] ||= {}
  directories = [ base_dir ]
  backup = false

  db = search(:mysql, "id:#{params[:name]}").first
  root_password = db[:root_password] || search(:credentials, "id:mysql").first[:default_root_password]

  directory "/u/mysql/scripts" do
    owner "root"
    group "root"
    mode 00700
    recursive true
  end

  %W(config data logs).each do |d|
    directories << "#{base_dir}/#{d}"
  end

  group "mysql" do
    gid node[:mysql][:gid]
    action [ :create, :manage ]
  end

  user "mysql" do
    uid node[:mysql][:uid]
    gid node[:mysql][:group_name]
    comment "MySQL Server"
    home "/u/mysql"
    action [ :create, :manage ]
  end

  [ node[:mysql][:root], "#{node[:mysql][:root]}/server" ].each do |dir|
    directory dir do
      owner "root"
      group "root"
      mode "0755"
      recursive true
    end
  end

  if params[:config][:binlog_dir]
    directory params[:config][:binlog_dir] do
      owner "mysql"
      group "mysql"
      mode 0755
      recursive true
    end
  else
    directories << "#{base_dir}/binlogs"
  end

  directories.each do |dir|
    directory dir do
      owner "mysql"
      group "mysql"
      mode 0755
      recursive true
    end
  end

  execute "install mysql binaries" do
    user "root"
    group "root"
    cwd "/tmp"
    command "tar -xjC #{node[:mysql][:root]}/server -f /home/system/pkg/mysql/mysql-#{params[:version]}.tar.bz2"
    creates mysql_dir
  end
  
  defaults = Mash.new({
    :datadir => "#{node[:mysql][:root]}/#{params[:name]}/data",
    :log_root => "#{node[:mysql][:root]}/#{params[:name]}/logs",
    :mysqld_error_log => "#{node[:mysql][:root]}/#{params[:name]}/logs/mysql.err",
    :port => "3306",
    :socket_path => "/tmp/mysql.#{params[:name]}.sock",
    :max_connections => 512,
    :slow_query_log => "#{node[:mysql][:root]}/#{params[:name]}/logs/mysql_slow_queries.log",
    :error_log => "#{node[:mysql][:root]}/#{params[:name]}/logs/mysql.log.err",
    :binlog_dir => "#{node[:mysql][:root]}/#{params[:name]}/binlogs/binlog",
    :innodb_log_dir => "#{node[:mysql][:root]}/#{params[:name]}/binlogs",
    :innodb_log_file_size => "200M",
    :innodb_log_buffer_size => "8M",
    :innodb_thread_concurrency => "4",
    :innodb_flush_log_at_trx_commit => "1",
    :innodb_flush_method => "O_DIRECT",
    :innodb_file_per_table => true,
    :innodb_buffer_pool_size => "500M",
    :key_buffer => "16M",
    :query_cache_size => "0",
    :pidfile => "#{node[:mysql][:root]}/#{params[:name]}/logs/mysql.pid",
    :server_id => "#{node[:ipaddress].split('.').last}#{params[:config][:port] || '3306'}",
    :binlogs_enabled => true,
    :sync_binlog => "1",
    :thread_cache => "64",
    :table_cache => "1024",
    :long_query_time => "2000000",
    :max_allowed_packet => "16M",
    :percona_patches => false,
    :auto_increment_increment => 1,
    :auto_increment_offset => 1,
    :log_slave_updates => true,
  })

  params[:config] = defaults.merge(params[:config])
  
  template "#{base_dir}/config/my.cnf.chef" do
    source "mysql.cnf.erb"
    owner "mysql"
    group "mysql"
    mode 0644
    variables(:params => params)
  end

  execute "copy chef mysql config" do
    user "mysql"
    group "mysql"
    command "cp #{base_dir}/config/my.cnf.chef #{base_dir}/config/my.cnf"
    creates "#{base_dir}/config/my.cnf"
  end

  execute "install empty database" do
    user "mysql"
    group "mysql"
    cwd "/tmp"
    command "#{node[:mysql][:root]}/server/#{params[:version]}/bin/mysql_install_db --defaults-file=#{base_dir}/config/my.cnf --user=mysql"
    creates "#{base_dir}/data/mysql/user.MYI"
  end
  
  template "/etc/init.d/mysql_#{params[:name]}" do
    source "init.sh.erb"
    owner "root"
    group "root"
    mode 0700
    backup false
    variables(:options => params, :node => node)
  end

  service "mysql_#{params[:name]}" do
    pattern "mysqld.*#{params[:name]}"
    action [ :enable, :start ] 
  end

  if params[:backup_location] && params[:perform_backups]
    package "xtrabackup"
    package "lzop"

    directory params[:backup_location] do
      owner "root"
      group "root"
      mode 00700
    end

    directory "#{base_dir}/scripts" do
      owner "root"
      group "root"
      mode 00700
    end

    template "#{base_dir}/scripts/backup.sh" do
      source "backup.sh.erb"
      owner "root"
      group "root"
      mode 00700
      backup false
      variables(:name => params[:name],
                :base_dir => base_dir,
                :backup_password => root_password,
                :destination => params[:backup_location],
                :socket => "/tmp/mysql.#{params[:name]}.sock")
    end

    backup = true
  end

  if backup
    template "/u/mysql/scripts/backup_all.sh" do
      source "backup_all.sh.erb"
      owner "root"
      group "root"
      mode 00700
      backup false
    end

    cron "backup databases" do
      minute 0
      hour 4
      command "/u/mysql/scripts/backup_all.sh"
      user "root"
      mailto "sysadmins@37signals.com"
    end
  end

  execute "mysql-install-privileges" do
    command "sleep 15 ; #{mysql_dir}/bin/mysql -u root -S /tmp/mysql.#{params[:name]}.sock < #{base_dir}/config/grants.sql ; touch #{base_dir}/config/.granted"
    action :nothing
    creates "#{base_dir}/config/.granted"
  end

  template "#{base_dir}/config/grants.sql" do
    source "grants.sql.erb"
    owner "root"
    group "root"
    mode "0600"
    variables({:user => params[:name],
               :database => "#{params[:name]}_production",
               :root_password => root_password, 
               :config => db
             })
    notifies :run, resources(:execute => "mysql-install-privileges"), :immediately
  end
end
