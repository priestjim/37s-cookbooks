
ree_filename = ["ruby-enterprise", node[:ree][:version], node[:ree][:architecture]].join("_")+".deb"

dpkg_package "ruby-enterprise" do
  source "/home/system/pkg/debs/#{ree_filename}"
end

include_recipe "ruby::gc_wrapper"
