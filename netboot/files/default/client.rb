#
# Chef Client Config File
#

log_level          :info
ssl_verify_mode    :verify_none
chef_server_url    "https://chef.sc-chi-int.37signals.com"

Chef::Log::Formatter.show_time = false
