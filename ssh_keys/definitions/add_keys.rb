define :add_keys do
  
  config = params[:conf]
  name = params[:name]
  keys = Mash.new
  keys[name] = node[:ssh_keys][name]
    
  template "/home/#{name}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    action :create
    cookbook "ssh_keys"
    owner name
    group config[:group].to_s
    variables(:keys => keys)
    mode 0600
  end
end