if node[:delayed_jobs]
  node[:delayed_jobs].each do |name, conf|
    bluepill_monitor "#{name}_dj" do
      cookbook "rails"
      source "bluepill_dj.conf.erb"
      rails_env conf[:env]
      log_path conf[:log_path] || "/tmp/bluepill_stdout.log"
      rails_root "/u/apps/#{name}/current"
      user "app"
      group "app"
      memory_limit 250 # megabytes
      cpu_limit 50 # percent
    end
  end
end