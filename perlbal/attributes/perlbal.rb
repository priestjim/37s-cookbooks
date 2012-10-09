perlbal Mash.new unless attribute?("perlbal")
perlbal[:config_path] = "/etc/perlbal" unless perlbal.has_key?(:config_path)
perlbal[:pools] = [] unless perlbal.has_key?(:pools)
perlbal[:proxies] = [] unless perlbal.has_key?(:proxies)
