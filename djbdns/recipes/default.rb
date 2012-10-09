include_recipe "build"
include_recipe "runit"

package "djbdns"

user "dnscache" do
  uid 9997
  gid "nogroup"
  shell "/bin/false"
  home "/home/dnscache"
end

user "dnslog" do
  uid 9998
  gid "nogroup"
  shell "/bin/false"
  home "/home/dnslog"
end

user "tinydns" do
  uid 9999
  gid "nogroup"
  shell "/bin/false"
  home "/home/tinydns"
end