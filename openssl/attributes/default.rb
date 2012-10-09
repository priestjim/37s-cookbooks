openssl Mash.new unless attribute?(:openssl)
openssl[:country_name] = "US"
openssl[:state_name] = "IL"
openssl[:locality_name] = "Chicago"
openssl[:company_name] = "37signals"
openssl[:organizational_unit_name] = "Operations"
openssl[:email_address] = "sysadmins@37signals.com"