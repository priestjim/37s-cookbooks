default.chef[:server_version] = "0.9.5"
default.chef[:server_path] = "#{languages[:ruby][:gems_dir]}/gems/chef-server-#{chef[:server_version]}"
default.chef[:server_api_path] = "#{languages[:ruby][:gems_dir]}/gems/chef-server-api-#{chef[:server_version]}"
default.chef[:server_webui_path] = "#{languages[:ruby][:gems_dir]}/gems/chef-server-webui-#{chef[:server_version]}"
default.chef[:webui_default_password] = '7bc318032e'
