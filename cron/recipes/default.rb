if node[:cron][:jobs]
  node[:cron][:jobs].each do |name, config|
    cron name do
      config.each do |k,v|
        send(k.to_sym, v)
      end
    end
  end
end