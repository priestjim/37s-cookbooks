#
# Cookbook Name:: activemq
# Attributes:: activemq
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

default.activemq[:dist_dir]  = "/home/system/pkg/misc"
default.activemq[:version] = "5.3.1"
default.activemq[:user] = "nobody"
default.activemq[:group] = "nogroup"
