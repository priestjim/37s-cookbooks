require_recipe "unicorn"

gem_package "tinder"
gem_package "cijoe"

directory "/etc/cijoe" do
  owner node[:cijoe][:user]
  owner node[:cijoe][:group]
end

directory node[:cijoe][:build_root] do
  owner node[:cijoe][:user]
  owner node[:cijoe][:group]
end

repos = []

node[:git][:repos].each do |name, conf|
  next unless conf[:ci]
  conf[:ci].each do |branch, branch_conf|
    
    full_name = "#{name}-#{branch}"
    full_path = "#{node[:cijoe][:build_root]}/#{full_name}"
    repos << {:full_name => full_name, :full_path => full_path}

    execute "cijoe initial build repo checkout for #{full_name}" do
      user node[:cijoe][:user]
      command "git clone #{node[:cijoe][:git_url_prefix]}:#{name}.git #{full_path}"
      not_if { File.directory?(full_path) }
    end

    execute "setup externals for #{full_name}" do
      cwd full_path
      user node[:cijoe][:user]
      command "cap local externals:setup"
      not_if  { File.exists?(full_path + "/vendor/rails") }
      only_if { File.exists?(full_path + "/config/externals.yml") }
    end

    execute "setup externals for #{full_name}" do
      cwd full_path
      user node[:cijoe][:user]
      command "gem bundle"
      only_if { File.exists?(full_path + "/Gemfile") }
    end
    
    execute "create database for #{full_name}" do
      cwd full_path
      command "rake db:create"
      environment "RAILS_ENV" => "test"
      not_if "mysql -u root -e 'show databases' | grep `grep database #{full_path}/config/database.yml | grep test | cut -d: -f2`"
    end

    execute "cijoe set active branch for #{full_name}" do
      user node[:cijoe][:user]
      cwd full_path
      command "git config --add cijoe.branch #{branch}"
      not_if "grep 'branch = #{branch}' #{full_path}/.git/config"
    end

    execute "cijoe setup campfire for #{full_name}" do
      user node[:cijoe][:user]
      cwd full_path
      command "git config --add campfire.user #{node[:ci][:campfire_token]} &&
               git config --add campfire.pass x &&
               git config --add campfire.subdomain #{node[:ci][:campfire_subdomain]} &&
               git config --add campfire.room #{node[:ci][:campfire_room]} &&
               git config --add campfire.ssl true"
      not_if "grep campfire #{node[:ci][:campfire_room]}/.git/config"
    end

    execute "cijoe setup test runner for #{full_name}" do
      cmd = branch_conf[:runner] || node[:cijoe][:runner]
      user node[:cijoe][:user]
      cwd full_path
      command "git config --add cijoe.runner \"#{cmd}\""
      not_if "grep '#{cmd}' #{full_path}/.git/config"
    end
  end
end

template "/etc/cijoe/config.ru" do
  variables :repos => repos
  mode 0644
end
template "/etc/cijoe/unicorn.conf.rb" do
  source "unicorn.conf.erb"
end

bluepill_monitor "cijoe" do
  cookbook "cijoe"
  source "bluepill.conf.erb"
  user node[:cijoe][:user]
  group node[:cijoe][:group]
  memory_limit 250 # megabytes
end