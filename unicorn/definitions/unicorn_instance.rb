define :unicorn_instance, :enable => true do

  template params[:conf_path] do
    source "unicorn.conf.erb"
    cookbook "unicorn"
    variables params
  end

  bluepill_monitor app do
    cookbook 'unicorn'
    source "bluepill.conf.erb"
    params.each { |k, v| send(k.to_sym, v) }
  end

end