if node[:utilities]
  node[:utilities].each do |name, config|
    cookbook_file "/usr/local/bin/#{name}" do
      config.each { |cmd, arg| send(cmd.to_sym, arg) } if config
      mode 0755
    end
  end
end