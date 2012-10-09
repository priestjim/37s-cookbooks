default.mysql[:root] = "/u/mysql"
default.mysql[:uid]  = 6000
default.mysql[:gid]  = 6000
default.mysql[:group_name]  = "mysql"
default.mysql[:perform_backups] = false
default.mysql[:backup_hour] = "06"
default.mysql[:xtrabackup_version] = "1.2-132.karmic.15"
