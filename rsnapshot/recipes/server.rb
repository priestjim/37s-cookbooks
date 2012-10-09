package "rsnapshot"

template "/etc/rsnapshot.conf" do
  source "rsnapshot.conf.erb"
end