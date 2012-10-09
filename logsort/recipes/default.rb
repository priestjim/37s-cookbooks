
apps = search(:apps)

apps.each do |app|
  if app[:syslog_files] && app[:syslog_files][:logsort]
    cookbook_file "/usr/local/bin/logsort.#{app[:id]}" do
      mode 0755
    end
  end
end
