default[:mysql][:mmm] = {
  :replication_user => "slave",
  :replication_password => "repl_pass",
  :agent_username => "mmm_agent",
  :agent_password => "agent_pass",
  :monitor_username => "mmm_mon",
  :monitor_password => "mon_pass",
  :hosts => {
    "db1" => { :ip_address => "1.2.3.4", :mode => 'master', :peer => "db1", :roles => %w(writer reader) },
    "db2" => { :ip_address => "1.2.3.5", :mode => 'master', :peer => "db2", :roles => %w(writer reader) },
    "db3" => { :ip_address => "1.2.3.6", :mode => 'slave',  :roles => %w(reader) }
  },
  :roles => {
    "writer" => { :ips => %w(192.168.0.1), :mode => "exclusive" },
    "reader" => { :ips => %w(192.168.0.1 192.168.0.2), :mode => "balanced" }
    
  }
}
