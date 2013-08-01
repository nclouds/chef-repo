#
# Cookbook Name:: graylog2
# Recipe:: server
#
# Copyright 2010, Medidata Solutions Inc.
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

# Install MongoDB from 10gen repository
include_recipe "mongodb::10gen_repo"
include_recipe "mongodb::default"

# Install required APT packages
package "openjdk-6-jre"

# Create the release directory
directory "#{node["graylog2"]["basedir"]}/rel" do
   mode 0755
   recursive true
end

# Download the elasticsearch dpkg
remote_file "elasticsearch_dpkg" do
    path "#{node["graylog2"]["basedir"]}/rel/elasticsearch-#{node["graylog2"]["elasticsearch"]["version"]}.deb"
    source "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{node["graylog2"]["elasticsearch"]["version"]}.deb"
    action :create_if_missing
end

dpkg_package "elasticsearch" do
    source "#{node["graylog2"]["basedir"]}/rel/elasticsearch-#{node["graylog2"]["elasticsearch"]["version"]}.deb"
    action :install
end

template "/etc/elasticsearch/elasticsearch.yml" do
    source "elasticsearch.yml.erb"
    variables( :server_name => node["graylog2"]["server_name"] )
    action :create
end

template "/etc/init.d/elasticsearch" do
    source "elasticsearch.erb"
    action :create
end

# Download the desired version of Graylog2 server from GitHub
remote_file "download_server" do
   path "#{node["graylog2"]["basedir"]}/rel/graylog2-server-#{node["graylog2"]["server"]["version"]}.tar.gz"
   source "https://github.com/Graylog2/graylog2-server/releases/download/0.12.0/graylog2-server-0.12.0.tar.gz"
   action :create_if_missing
end

# Unpack the desired version of Graylog2 server
execute "tar zxf graylog2-server-#{node["graylog2"]["server"]["version"]}.tar.gz" do
  cwd "#{node["graylog2"]["basedir"]}/rel"
  creates "#{node["graylog2"]["basedir"]}/rel/graylog2-server-#{node["graylog2"]["server"]["version"]}/build_date"
  action :nothing
  subscribes :run, resources(:remote_file => "download_server"), :immediately
end

# Link to the desired Graylog2 server version
link "#{node["graylog2"]["basedir"]}/server" do
  to "#{node["graylog2"]["basedir"]}/rel/graylog2-server-#{node["graylog2"]["server"]["version"]}"
end

# Create graylog2.conf
template "/etc/graylog2.conf" do
  source "graylog2-new.conf.erb"
  mode 0644
  variables( 
           :plugin_basedir => node["graylog2"]["plugin"]["basedir"],
           :graylog2_port  => node["graylog2"]["port"],
           :mongodb_auth => node["graylog2"]["mongodb"]["auth"],
           :mongodb_user => node["graylog2"]["mongodb"]["user"],
           :mongodb_password => node["graylog2"]["mongodb"]["password"],
           :mongodb_host => node["graylog2"]["mongodb"]["host"],
           :mongodb_database => node["graylog2"]["mongodb"]["database"],
           :mongodb_port => node["graylog2"]["mongodb"]["port"],
           :max_connections => node["graylog2"]["mongodb"]["max_connections"]
           )
  action :create
end

template "/etc/graylog2-elasticsearch.yml" do
  source "graylog2-elasticsearch.yml.erb"
  mode 0644
variables(
         :server_name => node["graylog2"]["server_name"],
         :node_name  =>  node["graylog2"]["node_name"]
         )
  action :create
end

# Create init.d script
template "/etc/init.d/graylog2" do
  source "graylog2.init.erb"
  mode 0755
end

# Update the rc.d system
execute "update-rc.d graylog2 defaults" do
  creates "/etc/rc0.d/K20graylog2"
  action :nothing
  subscribes :run, resources(:template => "/etc/init.d/graylog2"), :immediately
end

# Service resource
service "graylog2" do
  supports :restart => true
  action [:enable, :start]
end

service "elasticsearch" do
  action [:enable, :restart]
end
