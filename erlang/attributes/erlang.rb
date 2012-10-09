erlang Mash.new unless attribute?(:erlang)
erlang[:applications] = [] unless erlang.has_key?(:applications)

unless erlang.has_key?(:cookie)
  cookie = ""
  24.times {
    cookie <<
      (i = Kernel.rand(62);
       i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
  erlang[:cookie] = cookie
end
