#
# Cookbook Name:: webtalk
# Recipe:: default
#
# Copyright (C) 2017 Sando George
#
#

# Include the acme recipe to install the required gems.
include_recipe 'acme'

package 'unzip'
package 'software-properties-common'

apt_repository 'swi-prolog' do
  uri 'ppa:swi-prolog/devel'
  components ['main', 'devel']
end

apt_repository 'certbot' do
  uri 'ppa:certbot/certbot'
  components ['main', 'stable']
end

apt_update

package 'swi-prolog'
package 'certbot'

acme_selfsigned ENV['WEBTALK_SERVER_NAME'] do
  crt "/etc/ssl/#{ENV['WEBTALK_SERVER_NAME']}.crt"
  chain "/etc/ssl/#{ENV['WEBTALK_SERVER_NAME']}-chain.crt"
  key "/etc/ssl/#{ENV['WEBTALK_SERVER_NAME']}.key"
  guard_interpreter :bash
  not_if "[[ -f /etc/ssl/#{ENV['WEBTALK_SERVER_NAME']}.crt ]]"
end

directory '/usr/lib/swi-prolog/pack' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
  guard_interpreter :bash
  not_if '[[ -d /usr/lib/swi-prolog/pack ]]'
end

bash 'simple_template' do
  code 'swipl -g "pack_install(\'http://packs.rlaanemets.com/' +
           'simple-template/simple_template-1.1.0.tgz\', [interactive(false),' +
           ' package_directory(\'/usr/lib/swi-prolog/pack\')]), halt."'
  guard_interpreter :bash
  not_if '[[ -d /usr/lib/swi-prolog/pack/simple_template ]]'
end

remote_file "/tmp/logtalk_#{ENV['WEBTALK_LOGTALK_VERSION']}_all.deb" do
  source "http://logtalk.org/files/logtalk_#{ENV['WEBTALK_LOGTALK_VERSION']}_all.deb"
  mode 0644
  checksum "baedadcb5f3a8baa7e357d398daa2e96a5f71c7aeeac0fec94890f58f88dbf37"
end

dpkg_package "logtalk" do
  source "/tmp/logtalk_#{ENV['WEBTALK_LOGTALK_VERSION']}_all.deb"
  action :install
end

## Create and Set Permissions for Application Folder
directory '/srv/www/' do
  owner ENV['WEBTALK_USER']
  group ENV['WEBTALK_USER']
  mode '0775'
  action :create
  guard_interpreter :bash
  not_if '[[ -d /srv/www ]]'
end

## Get Webtalk source.
remote_file '/srv/www/master.zip' do
  source ENV['WEBTALK_SOURCE_URL']
  owner ENV['WEBTALK_USER']
  group ENV['WEBTALK_USER']
end

## Remove old extracted source.
bash 'remove_old_source' do
  code "rm -rf #{ENV['WEBTALK_SOURCE_DIR']}"
  cwd '/srv/www'
end

## Extract Webtalk source.
bash 'extract_webtalk_source' do
  code 'unzip master.zip'
  user ENV['WEBTALK_USER']
  cwd '/srv/www'
end

## Configure Webtalk server service.
template '/etc/systemd/system/webtalk.service' do
  source 'webtalk.erb'
  mode '0440'
  owner 'root'
  group 'root'
  variables({
      :daemonize => 'true',
      :https_only => 'true',
      :fork => 'false',
      :user => ENV['WEBTALK_USER'],
      :group => ENV['WEBTALK_USER'],
      :webtalk_server_name => ENV['WEBTALK_SERVER_NAME'],
      :working_dir => "/srv/www/#{ENV['WEBTALK_SOURCE_DIR']}",
  })
end

service 'webtalk.service' do
  provider Chef::Provider::Service::Systemd
  supports :reload => true
  action [:enable, :start]
end

node.set['acme']['contact'] = ["mailto:#{ENV['WEBTALK_ACME_CONTACT']}"]
acme_certificate  ENV['WEBTALK_SERVER_NAME'] do
  crt "/etc/ssl/#{ENV['WEBTALK_SERVER_NAME']}.crt"
  chain "/etc/ssl/#{ENV['WEBTALK_SERVER_NAME']}-chain.crt"
  key "/etc/ssl/#{ENV['WEBTALK_SERVER_NAME']}.key"
  wwwroot "/srv/www/#{ENV['WEBTALK_SOURCE_DIR']}/app"
  notifies :restart, 'service[webtalk.service]'
end