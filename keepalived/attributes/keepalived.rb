default.keepalived[:config_path] = "/etc/keepalived/keepalived.conf"
default.keepalived[:notification_email] = "sysadmins@37signals.com"
default.keepalived[:email_from] = "root@37signals.com"
default.keepalived[:smtp_host] = "192.168.2.40"
default.keepalived[:smtp_timeout] = 30
default.keepalived[:lvs_id] = node[:hostname]
default.keepalived[:vrrp_instances] = []
