require_recipe "god"

if node[:active_applications]
  node[:active_applications].each do |app, conf|
    full_name = "#{app}"
    path = "/u/apps/#{app}/current/config/god.conf.rb"

    god_monitor app do
      config_path path
      enable (conf[:god] || true)
    end

  end
end
