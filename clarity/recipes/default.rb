require_recipe "bluepill"
gem_package "clarity"

bluepill_monitor "clarity" do
  cookbook "clarity"
  source "bluepill.conf.erb"
  log_path node[:clarity][:log_path]
end

template "/etc/clarity.yml" do
  source "clarity.yml.erb"
  variables(:clarity => node[:clarity], :credentials => search(:credentials, "id:clarity").first)
end
