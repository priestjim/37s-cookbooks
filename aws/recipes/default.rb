gem_package "right_aws"

directory node[:aws][:path] do
  mode "0750"
  owner "root"
  group "www-data"
end