define :nagios_conf, :variables => {}, :config_subdir => true do
    
  subdir = if params[:config_subdir]
    "/#{node[:nagios][:config_subdir]}/"
  else
    "/"
  end
  
  template "#{node[:nagios][:root]}#{subdir}#{params[:name]}.cfg" do
    owner "nagios"
    group "nagios"
    source "#{params[:name]}.cfg.erb"
    mode 0644
    variables params[:variables]
    notifies :restart, resources(:service => "nagios3")
    backup 0
  end
end
