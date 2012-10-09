require_recipe "postfix"

package "postfix-pcre"

execute "update-postfix-virtual-domains" do
  command "/usr/sbin/postmap virtual"
  cwd "/etc/postfix"
  action :nothing
end

template "/etc/postfix/virtual" do
  source "virtual.erb"
  notifies :run, resources("execute[update-postfix-virtual-domains]")
  notifies :reload, resources(:service => "postfix")
end