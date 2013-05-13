#
# Cookbook Name:: meteor_windows
# Recipe:: default
# 

include_recipe "apt"
include_recipe "build-essential"
include_recipe "nodejs"
include_recipe "nodejs::npm"
include_recipe "git"
include_recipe "curl"

# install chef and leave a trail to prevent reinstalling each run
bash "install_meteor" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  curl https://install.meteor.com | sudo sh
  touch #{Chef::Config[:file_cache_path]}/meteor_installed_by_chef
  EOF
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/meteor_installed_by_chef") }
end

Chef::Log.info("Install Meteorite: #{node['meteor_windows']['install_meteorite']}")
Chef::Log.info("Meteor Command: #{node['meteor_windows']['meteor_command']}")

#Chef::Log.info("Env: #{node['meteor_windows']['env']}")
Chef::Log.info("Config: #{node['meteor_windows']['config']}")

if node['meteor_windows']['install_meteorite']
  bash "install_meteorite" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOF
    npm install -g meteorite
    touch #{Chef::Config[:file_cache_path]}/meteorite_installed_by_chef
    EOF
    not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/meteorite_installed_by_chef") }
  end
end

# Create home and sync directories
directory "#{node['meteor_windows']['sync_directory']}" do
  action :create
  recursive true
  owner node['meteor_windows']['owner']
  group node['meteor_windows']['group']
end

directory "#{node['meteor_windows']['home_directory']}" do
  action :create
  recursive true
  owner node['meteor_windows']['owner']
  group node['meteor_windows']['group']
end

apps = node['meteor_windows']['apps']

apps.each do |app|
  Chef::Log.info("Creating Meteor App: #{app}")

  # Create Destination folder for the database symlink mount of the created app
  directory "#{node['meteor_windows']['home_directory']}/#{app}" do
    action :create
    recursive true
    owner node['meteor_windows']['owner']
    group node['meteor_windows']['group']
  end

  # Create the Meteor App, move the hidden .meteor directory, and leave a breadcrumb to prevent recreating the app each run
  bash "meteor_create_#{app}" do
    cwd node['meteor_windows']['sync_directory']
    code <<-EOF
    #{node['meteor_windows']['meteor_command']} create #{app}
    mv #{node['meteor_windows']['sync_directory']}/#{app}/.meteor #{node['meteor_windows']['home_directory']}/#{app}/.meteor
    touch #{Chef::Config[:file_cache_path]}/meteor_#{app}_created_by_chef
    EOF
    not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/meteor_#{app}_created_by_chef") }
  end

  # Re-Create the moeve .meteor directory in order to map the symlink
  directory "#{node['meteor_windows']['sync_directory']}/#{app}/.meteor" do
    action :create
    recursive true
    owner node['meteor_windows']['owner']
    group node['meteor_windows']['group']
  end

  # Create a mount symlink from the sync directory to the home directory
  # This is required to move the Mongo DB location to a non-synced folder
  mount "#{node['meteor_windows']['sync_directory']}/#{app}/.meteor" do
    device "#{node['meteor_windows']['home_directory']}/#{app}/.meteor"
    fstype "none"
    options "bind,rw"
    action [:mount]
  end

  # This worked really well to start meteorite or meteor and add packages, but I couldn't get it to send a SIGINT (ctrl + c) to the process on the VM rather than try to stop vagrant ssh
  # Create convenience script to pass commands into vagrant ssh
  #if node['meteor_windows']['create_cmd_files']
  #  template "#{node['meteor_windows']['sync_directory']}/#{app}/#{node['meteor_windows']['meteor_command']}.cmd" do
  #    source "mrt.cmd.erb"
  #    owner node['meteor_windows']['owner']
  #    group node['meteor_windows']['group']
  #    variables({
  #      :appname => app
  #    })
  #  end
  #end
end

# Install ACPI Support Package and Power Button
if node['meteor_windows']['install_acpipowerbutton']

  package "acpi-support" do
    action :install
  end

  template "#{node['meteor_windows']['sync_directory']}/acpipowerbutton.cmd" do
    source "acpi.cmd.erb"
    owner node['meteor_windows']['owner']
    group node['meteor_windows']['group']
  end
end