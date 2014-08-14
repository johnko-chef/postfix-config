#
# Cookbook Name:: postfix-config
# Recipe:: default
#
# Author:: John Ko <git@johnko.ca>
# Copyright 2014, John Ko
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

include_recipe 'postfix::_common'

if platform?("freebsd")

  # Prevent service postfix from running from postfix recipe

  begin
    r1 = resources(:svc => "postfix")
    r1.action :nothing
  rescue Chef::Exceptions::ResourceNotFound
    Chef::Log.warn "could not find template to override!"
  end

  # Attempt to load my master.cf.erb with dovecot option

  begin
    r1 = resources(:template => "#{node['postfix']['conf_dir']}/master.cf")
    r1.cookbook "postfix-config"
  rescue Chef::Exceptions::ResourceNotFound
    Chef::Log.warn "could not find template to override!"
  end

  # Try to run postfix check, and restart with svc library

  execute "postfix-configtest" do
    command "postfix check"
    notifies :reload, 'svc[postfix]'
  end

end
