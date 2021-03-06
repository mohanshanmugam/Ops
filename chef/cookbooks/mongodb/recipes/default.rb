#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright 2011, edelight GmbH
# Authors:
#       Markus Korn <markus.korn@edelight.de>
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

package node[:mongodb][:package_name] do
  action :install
  version "#{node[:mongodb][:mongodb_version]}"
end

needs_mongo_gem = (run_context.loaded_recipe?("mongodb::replicaset") or run_context.loaded_recipe?("mongodb::mongos"))

if needs_mongo_gem
	['mongo', 'bson_ext'].each do |pkg|
		chef_gem pkg do
			action :install
		end
		# install the mongo ruby gem at compile time to make it globally available
		gem_package pkg do
			action :nothing
		end.run_action(:install)
	end
  Gem.clear_paths
end

if run_context.loaded_recipe?("mongodb::default") or run_context.loaded_recipe?("mongodb")
  # configure default instance
  mongodb_instance "mongodb" do
    mongodb_type "mongod"
    bind_ip      node['mongodb']['bind_ip']
    port         node['mongodb']['port']
    logpath      node['mongodb']['logpath']
    dbpath       node['mongodb']['dbpath']
    enable_rest  node['mongodb']['enable_rest']
  end
end

# if the host has ganglia, install the mongo plugin.
if node.recipes.include?("ganglia::default")
  include_recipe "ganglia::default"
  ganglia_python "mongodb" do
    action :enable
  end
end
