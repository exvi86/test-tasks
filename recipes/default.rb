#
# Cookbook Name:: jboss
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java_se"

jboss_source = node['jboss']['source']
jboss_file = node['jboss']['file']
jboss_path = node['jboss']['path']
jboss_user = node['jboss']['user']
listen_ip = node['jboss']['listen_ip']
app_source = node['app']['source']
app_path = node['app']['path']
app_file = node['app']['file']

yum_package 'unzip' do
    action :install
end

remote_file "#{jboss_file}" do
    not_if {File.exists?(jboss_path)}
    source "#{jboss_source}"
    owner "#{jboss_user}"
    group "#{jboss_user}"
    mode '0755'
    action :create
end

execute 'unzip_jboss' do
    not_if {File.exists?(jboss_path)}
    command "/bin/unzip #{jboss_file} -d #{jboss_path} && /bin/chown -R #{jboss_user}:#{jboss_user} #{jboss_path}"
end

template "/usr/lib/systemd/system/jboss.service" do
    source "jboss.service.erb"
    owner 'root'
    group 'root'
    mode '0755'
    variables({
        :jboss_user => jboss_user,
        :jboss_path => jboss_path
    })
end

template "#{jboss_path}/jboss-eap-6.4/standalone/configuration/standalone.xml" do
    source "standalone.xml.erb"
    owner "#{jboss_user}"
    group "#{jboss_user}"
    mode '0755'
    variables({
        :listenip => listen_ip
        })
end

service 'jboss' do
    provider Chef::Provider::Service::Init::Redhat
    action :nothing
end

remote_file "#{app_file}" do
    not_if {File.exists?(app_path)}
    source "#{app_source}"
    owner "#{jboss_user}"
    group "#{jboss_user}"
    mode '0755'
    action :create
end

execute 'unzip_app' do
    not_if {File.exists?(app_path)}
    command "/bin/unzip #{app_file} -d #{app_path} && /bin/chown -R #{jboss_user}:#{jboss_user} #{app_path}"
    notifies :restart, 'service[jboss]', :immediately
end

