require_recipe "aws"
require_recipe "mysql::client"

package "runit"

aws_credentials = search(:aws)

if node[:active_applications]

  directory "/u/apps" do
    owner "app"
    group "app"
    mode 0755
  end
  
  node[:active_applications].each do |name, conf|

    app = search(:apps, "id:#{name}").first
    app_name = conf[:app_name] || name
    app_root = "/u/apps/#{app_name}"
    aws_creds = aws_credentials.detect {|aws| aws[:id] == "#{name}-#{conf[:env]}" }
    directory "/u/apps/#{name}/shared/config" do
      recursive true
      owner "app"
      group "app"
    end
    
    if app[:packages]
      app[:packages].each do |package_name|
        package package_name
      end      
    end
    
    if app
      if app[:gems]
        app[:gems].each do |g|
          if g.is_a? Array
            gem_package g.first do
              version g.last
            end
          else
            gem_package g
          end
        end
      end
    
      if app[:symlinks]
        app[:symlinks].each do |target, source|
          link target do
            to source
          end
        end
      end
      if aws_creds
        template "#{app_root}/shared/config/s3.yml" do
          source "s3.yml.erb"
          variables aws_creds.to_hash
          cookbook "aws"
          backup false
          mode "0640"
          owner "app"
          group "app"
        end
      end
    end
  end
else
  Chef::Log.info "Add an :active_applications attribute to configure this node's apps"
end
