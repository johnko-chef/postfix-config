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

  # mynetworks should be the networks to trust
  set['postfix']['main']['mynetworks'] = '127.0.0.0/8 10.7.7.0/24 10.123.234.0/24'
  # override common
  set['postfix-config']['domain_for_destination'] = node['postfix']['main']['mydomain']
  set['postfix']['main']['use_alias_maps'] == 'yes'
  set['postfix']['main']['mydestination'] = [node['postfix-config']['domain_for_destination'], node['postfix']['main']['myhostname'], node['hostname'], 'localhost.localdomain', 'localhost'].compact
  set['postfix']['main']['home_mailbox'] = 'Maildir/'
  message_size_limit = '52428800'
  maximal_backoff_time = 600
  set['postfix']['main']['mailbox_command'] = '/usr/lib/dovecot/deliver -c /etc/dovecot/conf.d/01-dovecot-postfix.conf -n -m "${EXTENSION}"'

  #override server
  case node['postfix']['mail_type']
  when 'master'
    # port 587/submission
    set['postfix']['master']['submission'] = true
    # ca
    set['postfix']['main']['smtpd_use_tls'] = 'yes'
    set['postfix']['main']['smtpd_tls_cert_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    set['postfix']['main']['smtpd_tls_key_file'] = '/etc/ssl/private/ssl-cert-snakeoil.key'
    # SSL/TLS
    set['postfix']['main']['smtpd_tls_received_header'] = 'yes'
    set['postfix']['main']['smtpd_tls_mandatory_protocols'] = 'SSLv3, TLSv1'
    set['postfix']['main']['smtpd_tls_mandatory_ciphers'] = 'medium'
    set['postfix']['main']['smtpd_enforce_tls'] = 'yes'
    set['postfix']['main']['smtpd_tls_auth_only'] = 'yes'
    set['postfix']['main']['smtpd_delay_reject'] = 'yes'
    set['postfix']['main']['tls_random_source'] = 'dev:/dev/random'
    # restrictions
    set['postfix']['main']['smtpd_sender_restrictions'] = "reject_unknown_sender_domain check_sender_access hash:#{node['postfix']['conf_dir']}/restricted_senders"
    set['postfix']['main']['smtpd_client_restrictions'] = 'permit_sasl_authenticated, reject'
    set['postfix']['main']['smtpd_recipient_restrictions'] = 'reject_unknown_sender_domain, reject_unknown_recipient_domain, reject_unauth_pipelining, permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'
    set['postfix']['main']['smtpd_restriction_classes'] = 'local_only'
    set['postfix']['main']['local_only'] = "check_recipient_access hash:#{node['postfix']['conf_dir']}/local_domains, reject"
    # smtpd sasl
    set['postfix']['main']['smtpd_sasl_auth_enable'] = 'yes'
    set['postfix']['main']['smtpd_sasl_type'] = 'dovecot'
    set['postfix']['main']['smtpd_sasl_path'] = 'private/dovecot-auth'
    set['postfix']['main']['smtpd_sasl_authenticated_header'] = 'yes'
    set['postfix']['main']['smtpd_sasl_security_options'] = 'noanonymous'
    set['postfix']['main']['smtpd_sasl_tls_security_options'] = 'noanonymous'
    set['postfix']['main']['smtpd_sasl_local_domain'] = '$myhostname'
    set['postfix']['main']['broken_sasl_auth_clients'] = 'yes'
  end

  # override client
  set['postfix']['main']['smtp_use_tls'] = 'yes'
  set['postfix']['main']['smtp_sasl_auth_enable'] == 'yes'
  set['postfix']['sasl']['smtp_sasl_user_name'] = ''
  set['postfix']['sasl']['smtp_sasl_passwd']    = ''
  set['postfix']['main']['smtp_sasl_security_options'] = ''
  set['postfix']['main']['smtp_sasl_tls_security_options'] = ''
  set['postfix']['main']['relayhost'] = '[outbound.mailhop.org]:2525'
  set['postfix']['main']['relay_domains'] = node['postfix']['main']['mydomain']
end
