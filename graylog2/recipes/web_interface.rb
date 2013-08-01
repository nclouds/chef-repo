#
# Cookbook Name:: graylog2
# Recipe:: web_interface
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

# Install required APT packages
 [ "build-essential",
   "ruby1.9.1",
   "ruby1.9.1-dev",
   "build-essential", 
   "libcurl4-openssl-dev", 
   "libssl-dev", 
   "zlib1g-dev",
   "libpcre3-dev",
   "apache2-mpm-prefork", 
   "apache2-prefork-dev", 
   "libapr1-dev",
   "libaprutil1-dev",
   "postfix"].each do |pkg|
  package pkg do
  action :install
  end
  end

#Link required binaries
execute "links" do
command "cd /usr/bin;ln -sf ruby1.9.1 ruby;ln -sf gem1.9.1 gem;ln -sf erb1.9.1 erb;ln -sf irb1.9.1 irb;ln -sf rake1.9.1 rake;ln -sf rdoc1.9.1 rdoc;ln -sf testrb1.9.1 testrb"
end

# Install gem dependencies
gem_package "bundler" do
action :install
end

gem_package "passenger" do
action :install
version "3.0.18"
end

#Linking required binaries
execute "bundle-link" do
command "ln -sf /var/lib/gems/1.9.1/bin/bundle /usr/bin/bundle"
end

# Create the release directory
directory "#{node["graylog2"]["basedir"]}/rel" do
mode 0755
recursive true
end

remote_file "#{node["graylog2"]["basedir"]}/rel/graylog2-web-interface-#{node["graylog2"]["web_interface"]["version"]}.tar.gz" do
source "https://github.com/Graylog2/graylog2-web-interface/releases/download/0.12.0/graylog2-web-interface-0.12.0.tar.gz"
action :create_if_missing
end

# Unpack the desired version of Graylog2 web interface
execute "extract" do
command "cd #{node["graylog2"]["basedir"]};tar -xzf #{node["graylog2"]["basedir"]}/rel/graylog2-web-interface-#{node["graylog2"]["web_interface"]["version"]}.tar.gz;mv #{node["graylog2"]["basedir"]}/graylog2-web-interface-#{node["graylog2"]["web_interface"]["version"]} #{node["graylog2"]["basedir"]}/web"
end

#Placing secret key file
template "#{node["graylog2"]["basedir"]}/web/config/initializers/secret_token.rb" do
source "secret_token.rb.erb"
action :create
end

# Create mongoid.yml
template "#{node["graylog2"]["basedir"]}/web/config/mongoid.yml" do
source "mongoid.yml.erb"
mode 0644
  variables(
          :mongodb_host => node["graylog2"]["mongodb"]["host"],
          :mongodb_database => node["graylog2"]["mongodb"]["database"],
          :mongodb_port => node["graylog2"]["mongodb"]["port"],
          :mongodb_auth => node["graylog2"]["mongodb"]["auth"],
          :mongodb_user => node["graylog2"]["mongodb"]["user"],
          :mongodb_password => node["graylog2"]["mongodb"]["password"]
          )
end

# Create general.yml
template "#{node["graylog2"]["basedir"]}/web/config/general.yml" do
source "general.yml.erb"
owner "nobody"
group "nogroup"
mode 0644
variables( :external_hostname => node["graylog2"]["external_hostname"] )
end

# Chown the Graylog2 directory to www-data/www-data to allow web servers to serve it
execute "chperm" do
command "sudo chown -R www-data:www-data #{node["graylog2"]["basedir"]}/web"
end

# Perform bundle install on the newly-installed Graylog2 web interface version
execute "bundle install" do
command "cd #{node["graylog2"]["basedir"]}/web && bundle install --without=development"
end
