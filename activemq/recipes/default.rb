#
# Cookbook Name:: activemq
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java"
include_recipe "runit"

amq_user = node[:activemq][:user]
amq_group = node[:activemq][:group]
version = node[:activemq][:version]
dist_dir = node[:activemq][:dist_dir]

directory "/opt" do
  owner "root"
  group "root"
  mode 00755
end

unless File.exists?("/opt/apache-activemq-#{version}/bin/activemq")
  execute "extract activemq" do
    command "tar zxf #{dist_dir}/apache-activemq-#{version}-bin.tar.gz && chown -R #{amq_user}:#{amq_group} apache-activemq-#{version}"
    cwd "/opt"
  end
end

directory "/opt/apache-activemq-#{version}" do
  owner amq_user
  group amq_group
end

file "/opt/apache-activemq-#{version}/bin/activemq" do
  owner amq_user
  group amq_group
  mode "0755"
end

runit_service "activemq" do
  cookbook "activemq"
end
