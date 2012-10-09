require_recipe "git"
require_recipe "gitosis"
 
directory node[:git][:repo_root] do
  owner "git"
  group "git"
  mode 0755
end

directory node[:git][:repo_root]+"/bin" do
  owner "git"
  group "git"
  mode 0755
end

cookbook_file node[:git][:repo_root]+"/bin/update_mirrors.rb" do
  source "update_mirrors.rb"
  mode 0755
end

cron "update git mirrors" do 
  command "#{node[:git][:repo_root]}/bin/update_mirrors.rb"
  user "git"
  minute "*/5"
end  

search(:git_repos, "*:*").each do |repo, config|

  repo_path = "/#{node[:git][:repo_root]}/#{repo}.git"
  
  directory repo_path do
    owner "git"
    group "git"
    mode "2775"
  end

  execute "initialize new shared git repo" do
    command "cd #{repo_path} && git --bare init --shared"
    only_if { !File.exists? "#{repo_path}/HEAD" }
  end

  # install hooks
  
  template "#{repo_path}/hooks/post-receive" do
    source "post-receive-hook.erb"
    owner "git"
    group "git"
    variables :repo => repo, :config => config
    mode 0755
  end
end