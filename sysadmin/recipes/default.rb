case node[:platform]
when "debian", "ubuntu"
  package "policykit"
  package "emacs22-nox"
  require_recipe "apt"
else 
  package "emacs-nox"
end

package "vim"
package "curl"
package "man-db"
package "strace"
package "host"
package "lsof"
package "gdb"
package "socat"
package "procmail"
package "zsh"
package "ack-grep"

directory "/u/system" do
  owner "root"
  group "admin"
  mode 0755
end

directory "/u/system/bin" do
  owner "root"
  group "admin"
  mode 0755  
end

%w(memory_stats rotate-email-folders rotate-misc-log rotate-db-backups).each do |file|
  remote_file "/usr/local/bin/#{file}" do
    source file
    mode 0755
  end
end
