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

default['postfix']['master']['dovecot'] = false

case node['platform_family']
when 'freebsd'
  # start defaults in 2.11.1_2,1 on freebsd:10:x86:64
  set['postfix']['main']['queue_directory'] = '/var/spool/postfix'
  set['postfix']['main']['command_directory'] = '/usr/local/sbin'
  set['postfix']['main']['daemon_directory'] = '/usr/local/libexec/postfix'
  set['postfix']['main']['data_directory'] = '/var/db/postfix'
  set['postfix']['main']['mail_owner'] = 'postfix'
  set['postfix']['main']['unknown_local_recipient_reject_code'] = '550'
  set['postfix']['main']['mynetworks_style'] = 'host'
  set['postfix']['main']['debug_peer_level'] = '2'
  set['postfix']['main']['debugger_command'] = 'PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin ddd $daemon_directory/$process_name $process_id & sleep 5'
  set['postfix']['main']['sendmail_path'] = '/usr/local/sbin/sendmail'
  set['postfix']['main']['newaliases_path'] = '/usr/local/bin/newaliases'
  set['postfix']['main']['mailq_path'] = '/usr/local/bin/mailq'
  set['postfix']['main']['setgid_group'] = 'maildrop'
  set['postfix']['main']['html_directory'] = '/usr/local/share/doc/postfix'
  set['postfix']['main']['manpage_directory'] = '/usr/local/man'
  set['postfix']['main']['sample_directory'] = '/usr/local/etc/postfix'
  set['postfix']['main']['readme_directory'] = '/usr/local/share/doc/postfix'
  set['postfix']['main']['inet_protocols'] = 'ipv4'
  # end defaults in 2.11.1_2,1 on freebsd:10:x86:64  #defaults server

  case node['postfix']['mail_type']
  #override server
  when 'master'
    override['postfix']['master']['submission'] = true
    override['postfix']['main']['smtpd_sender_restrictions'] = 'reject_unknown_sender_domain'
    override['postfix']['main']['smtpd_client_restrictions'] = 'permit_sasl_authenticated, reject'
  end

  #override client
end
