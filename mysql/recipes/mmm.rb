
require_recipe 'perl'

# Install MMM Perl dependencies
%w(Algorithm::Diff Class::Singleton DBI DBD::mysql File::Basename File::stat File::Temp
   Log::Dispatch Log::Log4perl Mail::Send Net::Ping Net::ARP Proc::Daemon Thread::Queue
   Time::HiRes).each do |mod|
  cpan_module mod
end

# Install the mmm scripts from source
bash "install mmm" do
  user "root"
  cwd "/tmp"
  code <<-EOH
wget -O mmm.tar.gz http://mysql-mmm.org/_media/:mmm2:mysql-mmm-2.0.10.tar.gz
tar xfz mmm.tar.gz
cd mysql-mmm-2.0.10
make install
  EOH
  
  not_if { File.exist?("/usr/sbin/mmmd_agent") }
end

%w(mmm_agent mmm_common mmm_mon mmm_tools).each do |file|
  template "/etc/mysql-mmm/#{file}.conf" do
    source "#{file}.conf.erb"
    owner "root"
    group "root"
    mode "0600"
  end  
end
