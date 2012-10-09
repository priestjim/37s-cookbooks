define :passenger_monitor do
  remote_file "/usr/local/bin/passenger_monitor" do
    source "passenger_monitor"
    cookbook "passenger"
  end
  cron "passenger memory monitor" do
    command ""
    hour "5"
    user "app"
  end
end