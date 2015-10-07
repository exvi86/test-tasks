#
# Cookbook Name:: jboss
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

jboss_source = node['jboss']['source']
jboss_file = node['jboss']['file']
jboss_path = node['jboss']['path']
listen_ip = node['jboss']['listen_ip']
app_source = node['app']['source']
app_path = node['app']['path']
app_file = node['app']['file']

remote_file "#{jboss_file}" do
    not_if {File.exists?(jboss_path)}
    source "#{jboss_source}"
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    action :create
end

execute 'unzip_jboss' do
    not_if {File.exists?(jboss_path)}
    command '/bin/unzip #{jboss_file} -d "#{jboss_path}"'
end

remote_file "#{app_file}" do
    not_if {File.exists?(app_path)}
    source "#{app_source}"
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    action :create
end

execute 'unzip_app' do
    not_if {File.exists?(app_path)}
    command '/bin/unzip #{app_file} -d #{app_path}'
end

template "#{jboss_path}/standalone/configuration/standalone.xml" do
    source "standalone.xml.erb"
    owner "vagrant"
    group "vagrant"
    mode "0755"
    variables({
	:listenip => listen_ip
	})
end
