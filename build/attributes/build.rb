build Mash.new unless attribute?("build")
build[:ruby_enterprise_edition] = {:packages => ["libssl-dev", "libreadline5-dev", "bison"]}
