require_recipe "nginx"
require_recipe "thin"
require_recipe "resque"

bluepill_monitor "resque-web" do
  cookbook "resque"
  source "bluepill_web.conf.erb"
end