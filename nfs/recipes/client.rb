package "nfs-common"

include_recipe "users"

nfs_mounts = {}

if node[:active_applications]
  node[:active_applications].each do |name, conf|
    app = search(:apps, "id:#{name}").first
    next unless app[:environments] && app[:environments][conf["env"]] && conf["mount_nfs"] != "false"
    app_config =  app[:environments][conf["env"]]
    nfs_mounts.merge!(app_config[:nfs_mounts]) if app_config[:nfs_mounts]
  end
end

nfs_mounts.merge!(node[:nfs_mounts]) if node[:nfs_mounts]

nfs_mounts.each do |target, config|
  directory target do
    recursive true
    owner config[:owner]
    group config[:owner]
  end
  
  mount target do
    fstype "nfs"
    options config[:options] || %w(rsize=32768,wsize=32768,bg,hard,nfsvers=3,intr,tcp)
    device config[:device]
    dump 0
    pass 0
    # mount and add to fstab. set to 'disable' to remove it
    action [:enable, :mount]
  end
end
