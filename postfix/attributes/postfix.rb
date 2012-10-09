default.postfix[:myorigin] = node[:fqdn]
default.postfix[:message_size_limit] = 15728640
default.postfix[:destination_concurrency_limit] = 5