default['meteor_windows']['install_meteorite'] = true
if !node['meteor_windows']['install_meteorite']
  default['meteor_windows']['meteor_command'] = 'meteor'
else
  default['meteor_windows']['meteor_command'] = 'mrt'
end
#default['meteor_windows']['create_cmd_files'] = true
default['meteor_windows']['install_acpipowerbutton'] = false
default['meteor_windows']['sync_directory'] = '/vagrant'
default['meteor_windows']['home_directory'] = '/home/vagrant'
default['meteor_windows']['mount_directory'] = '.meteor/local'
default['meteor_windows']['owner'] = 'vagrant'
default['meteor_windows']['group'] = 'vagrant'