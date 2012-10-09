require_recipe "nginx"

gem_package "passenger-enterprise-server" do
  version node[:passenger][:nginx][:passenger_version]
end

package "libgeoip-dev"
package "libxslt1-dev"
package "libpcre3-dev"
package "libgd2-noxpm-dev"
package "libssl-dev"

nginx_path = "/tmp/nginx-#{node[:passenger][:nginx][:nginx_version]}"

remote_file nginx_path + ".tar.gz" do
  cookbook "nginx"
  source "nginx-#{node[:passenger][:nginx][:nginx_version]}.tar.gz"
end

execute "extract nginx" do
  command "tar -C /tmp -xzf #{nginx_path}.tar.gz"
  not_if { File.exists?(nginx_path) }
end

# default options from Ubuntu 8.10
compile_options = ["--conf-path=/etc/nginx/nginx.conf",
                   "--error-log-path=/var/log/nginx/error.log",
                   "--pid-path=/var/run/nginx.pid",
                   "--lock-path=/var/lock/nginx.lock",
                   "--http-log-path=/var/log/nginx/access.log",
                   "--http-client-body-temp-path=/var/lib/nginx/body",
                   "--http-proxy-temp-path=/var/lib/nginx/proxy",
                   "--http-fastcgi-temp-path=/var/lib/nginx/fastcgi",
                   "--with-http_stub_status_module",
                   "--with-http_ssl_module",
                   "--with-http_gzip_static_module",
                   "--with-http_geoip_module",
                   "--with-file-aio"].join(" ")

execute "compile nginx with passenger" do
  command "passenger-install-nginx-module --auto --prefix=/usr --nginx-source-dir=#{nginx_path} --extra-configure-flags=\"#{compile_options}\""
  notifies :restart, resources(:service => "nginx")
  not_if "nginx -V | grep passenger-enterprise-server-#{node[:passenger][:nginx][:nginx_version]}"
end

template node[:nginx][:conf_dir] + "/passenger.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "nginx")
end