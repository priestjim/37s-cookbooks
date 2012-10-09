#!/usr/local/bin/ruby
#
# Nagios check for Ganglia metrics
# Copyright 37signals, 2010
# Author: John Williams (john@37signals.com)

require 'rubygems'
require 'choice'

gmetric_path = "/usr/bin/gmetric"

Choice.options do
  header ''
  header 'Specific options:'

  option :path do
    short '-p'
    long '--path=VALUE'
    desc 'Path to socket file'
  end
end

c = Choice.choices

backends = `echo "show stat" | socat #{c[:path]} stdio`.strip

backends.each do |line|
  values = line.split(",")
  if values[0] == "asset_hosts" || values[0] == "app_hosts"
    app_name = c[:path].split("/").last.split(".").first
    name_prefix = "#{app_name}_haproxy_#{values[0]}_#{values[1]}".downcase
    current_queue = values[2]
    commands = []
    commands << "#{gmetric_path} --type=float --name=#{name_prefix}_queue --value=#{values[2]} --unit=sessions"
    commands << "#{gmetric_path} --type=float --name=#{name_prefix}_sessions --value=#{values[4]} --unit=sessions"
    commands << "#{gmetric_path} --type=float --name=#{name_prefix}_session_rate --value=#{values[33]} --unit=sessions/sec" 
    commands.each do |command|
      system(command)
    end
  end
end