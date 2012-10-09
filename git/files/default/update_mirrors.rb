#!/usr/local/bin/ruby
#
# git mirror updater
#

mirrors_root = ARGV[0]
repos = Dir.glob("#{mirrors_root}/*.git")

repos.each do |repo|
  Dir.chdir repo
  puts system("git fetch origin refs/heads/*:refs/heads/* && git gc && git update-server-info")
end