default.mogilefs[:path] = "/u/apps/mogilefs" 
default.mogilefs[:trackers] = ['mogilefs:6001']
default.mogilefs[:pkg] = "http://dist/packages/mogilefs.tar.bz2" 

default.mogilefs[:mogilefsd][:db_dsn] = "DBI:mysql:database=mogilefs;host=mogiledb;port=3306"
default.mogilefs[:mogilefsd][:db_user] = "mogile"
default.mogilefs[:mogilefsd][:db_pass] = "12345678"
default.mogilefs[:mogilefsd][:conf_port] = 6001
default.mogilefs[:mogilefsd][:listener_jobs] = 10
default.mogilefs[:mogilefsd][:delete_jobs] = 1
default.mogilefs[:mogilefsd][:replicate_jobs] = 5
default.mogilefs[:mogilefsd][:reaper_jobs] = 1
default.mogilefs[:mogilefsd][:mog_root] = "/var/mogdata"

default.mogilefs[:mogstored][:http_listen] = "0.0.0.0:7500"
default.mogilefs[:mogstored][:mgmt_listen] = "0.0.0.0:7501"
default.mogilefs[:mogstored][:doc_root] = "/var/mogdata"