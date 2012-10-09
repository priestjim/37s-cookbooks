default.collectd[:base_dir] = "/var/lib/collectd"
default.collectd[:plugin_dir] = "/usr/lib/collectd"
default.collectd[:types_db] = ["/usr/lib/collectd/types.db", "/etc/collectd/my_types.db"]
default.collectd[:interval] = 10
default.collectd[:read_threads] = 5
default.collectd[:server_address] = %w(192.168.1.153 192.168.1.159)
default.collectd[:server] = false
default.collectd[:plugins] =
    [
     { "name" => "syslog", "options" => [{ "LogLevel" => "Info"  }]},
     { "name" => "cpu" },
     { "name" => "df", "options" => [{ "Device" => "/dev/vda1" }, { "Device" => "/dev/sda1" }]},
     { "name" => "disk", "options" => [{ "Disk" => "vda1" }, { "Disk" => "sda1" }]},
     { "name" => "interface", "options" => [{ "Interface" => "eth0" }, { "Interface" => "eth1"}]},
     { "name" => "memory" },
     { "name" => "rrdtool", "options" => [{ "DataDir" => "/var/lib/collectd/rrd" }, { "CacheFlush" => 120 }, { "WritesPerSecond" => 75 }]},
     { "name" => "swap" }
    ];
