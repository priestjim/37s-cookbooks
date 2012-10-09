memcached Mash.new unless attribute?("memcached")

memcached[:conf_path] = "/etc/memcached.conf"
memcached[:max_memory] = 256 unless memcached.has_key?(:max_memory)
memcached[:max_connections] = 1024 unless memcached.has_key?(:max_connections)
memcached[:port] = 11211 unless memcached.has_key?(:port)
memcached[:user] = "nobody" unless memcached.has_key?(:user)
memcached[:log_path] = "/var/log/memcached.log"