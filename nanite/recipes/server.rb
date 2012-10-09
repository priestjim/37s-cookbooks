
include_recipe "nanite"
include_recipe "rabbitmq"
include_recipe "redis"

execute "rabbitmqctl add_vhost /nanite" do
  not_if "rabbitmqctl list_vhosts | grep /nanite"
end

passwords = data_bag_item("nanite", "passwords")

%w[mapper nanite].each do |agent|
  execute "rabbitmqctl add_user #{agent} #{passwords[agent]}" do
    not_if "rabbitmqctl list_users | grep #{agent}"
  end
end

execute 'rabbitmqctl set_permissions -p /nanite mapper ".*" ".*" ".*"' do
  not_if 'rabbitmqctl list_user_permissions mapper | grep /nanite'
end

execute 'rabbitmqctl set_permissions -p /nanite nanite "^nanite.*" ".*" ".*"' do
  not_if 'rabbitmqctl list_user_permissions nanite | grep /nanite'
end
