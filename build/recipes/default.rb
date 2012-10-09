%w{build-essential binutils-doc}.each do |pkg|
  package pkg do
    action :install
  end
end

package "autoconf" do
  action :install
end

package "flex" do
  action :install
end

package "bison" do
  action :install
end

gem_package "git_remote_branch"

directory "/usr/local/build" do
  action :create
  owner "root"
  group "admin"
  mode 0775
end

if node[:build]
  node[:build].each do |name, config|
    config[:packages].each do |pack|
      package pack
    end
  end
end