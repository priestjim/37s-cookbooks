#!/usr/bin/env ruby

# Integrity periodic build script. 
# Original: http://gist.github.com/88432

ENV["RAILS_ENV"] = "test"
ENV["PATH"] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
 
require 'rubygems'
require 'integrity'
require 'notifier/campfire'
 
Integrity::Notifier.register(Integrity::Notifier::Campfire)
 
Integrity.new(File.dirname(__FILE__) + "/config.yml")
 
Integrity::Project.all.each do |project|
  last_commit = project.commits.last
  build = last_commit ? project.send(:head_of_remote_repo) != last_commit.identifier : false
  project.build if build || project.commits.last.nil?
end

