script "install sphinx" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  
  code <<-EOH
tar xfz /home/system/pkg/sphinx/sphinx-#{node[:sphinx][:version]}.tar.gz && \
cd sphinx-#{node[:sphinx][:version]} && \
./configure --prefix=/usr/local && \
make install
rm -rf /tmp/sphinx-#{node[:sphinx][:version]}.tar.gz /tmp/sphinx-#{node[:sphinx][:version]}
EOH
  not_if { File.exist?("/usr/local/bin/search") && `/usr/local/bin/search`.match(/Sphinx #{node[:sphinx][:version]}/) }
end

node[:active_applications].each do |name, config|
  
  app = search(:apps, "id:#{name}").first
  
  next unless app[:sphinx]

  directory "/u/apps/#{name}/shared/sphinx" do
    action :create
    recursive true
    owner "app"
    group "app"
    mode "0755"
  end
  
  bluepill_monitor "sphinx_#{name}" do
    source "bluepill_sphinx.conf.erb"
    rails_root "/u/apps/#{name}/current"
    config_file config[:env] == "staging" ? 'staging.conf' : 'production.conf'
    user "app"
    group "app"
  end  

  logrotate "sphinx_#{name}" do
    restart_command "kill -USR1 `cat /u/apps/#{name}/shared/pids/searchd.pid`"
    files "/u/apps/#{name}/shared/log/*.log"
    frequency "daily"
  end
end

