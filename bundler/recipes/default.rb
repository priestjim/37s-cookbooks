execute "uninstall old bundlers" do
  command "gem uninstall -a bundler"
  only_if "gem list bundler | grep ,"
end

gem_package "bundler" do
  version node[:bundler][:version]
end