require_recipe "nginx"
require_recipe "fcgiwrap"
require_recipe "git::server"
include_recipe "users"

package 'spawn-fcgi'
package "gitweb"

directory node[:gitweb][:config_path] do
  mode 0755
  recursive true
end

template "/etc/gitweb/nginx.conf"

template "/etc/gitweb/projects.conf" do
  variables :projects => (search(:git_repos, "*:*"))
end

nginx_site "gitweb" do
  config_path "/etc/gitweb/nginx.conf"
end

htpasswd_file "/etc/gitweb/htpasswd.users" do
  owner "nagios"
  group "www-data"
  mode 0640
end