
package "erlang"

template "/home/app/.erlang.cookie" do
  source "erlang.cookie.erb"
  owner "app"
  group "app"
  mode 00600
end

execute "install mysql library" do
  user "root"
  cwd "/usr/lib/erlang/lib"
  command "curl http://dist/packages/erlang/mysql-02.17.2009.tar.bz2 | tar xfj -"
  creates "/usr/lib/erlang/lib/mysql-02.17.2009/ebin/mysql.beam"
end

execute "install mochiweb library" do
  user "root"
  cwd "/usr/lib/erlang/lib"
  command "curl http://dist/packages/erlang/mochiweb-02.24.2009.tar.bz2 | tar xfj -"
  creates "/usr/lib/erlang/lib/mochiweb-02.24.2009/ebin/mochiweb.beam"
end

node[:erlang][:applications].each do |app|
  template "/usr/local/bin//erlang_#{app[:name]}" do
    source "erlang.init.erb"
    variables(:app => app)
    owner "root"
    group "root"
    mode 00755
    backup false
  end

  runit_service "erlang_#{app[:name]}" do
    template_name "erlang"
    options({ :app => app })
  end

  service "erlang_#{app[:name]}" do
    action :enable
  end  
end

