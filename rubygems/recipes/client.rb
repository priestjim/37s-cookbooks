if !node[:rubygems][:sources].empty?
  template "/etc/gemrc" do
    source "gemrc.erb"
    mode 0644
  end
end

execute "update rubygems" do
  command "gem install rubygems-update -v #{node[:rubygems][:version]} --no-rdoc --no-ri && update_rubygems"
  not_if { `gem -v`.chomp == node[:rubygems][:version] }
end
