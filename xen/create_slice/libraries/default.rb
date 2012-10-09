def generate_mac_address
  "00:16:3E:%X%X:%X%X:%X%X" % Array.new(6) { rand(16) }
end