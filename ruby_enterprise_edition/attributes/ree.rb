default.ree[:version] = "1.8.7-2010.01"
default.ree[:architecture] = node[:kernel][:machine] == "x86_64" ? "amd64" : "i386"
