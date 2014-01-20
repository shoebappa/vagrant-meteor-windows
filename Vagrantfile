# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_plugin "vagrant-vbguest"
Vagrant.require_plugin "vagrant-omnibus"
Vagrant.require_plugin "vagrant-berkshelf"

Vagrant.configure("2") do |config|

  config.vm.box = "opscode32"

  # This Opscode box is used because the default Vagrant boxes come with an older version of chef, which the nodejs package option don't work with.
  # To use another box, you will need to remove the nodejs install_method from the chef.json which will use the default method of source, which takes a while
  config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_chef-11.4.4.box"

  config.vm.network  :private_network, ip: "10.11.12.13"

  config.berkshelf.enabled = true

  config.omnibus.chef_version = :latest

  # This VM config option is required in order to be able to create the mount --bind symlink to the sync folder
  config.vm.provider "virtualbox" do |v|
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant-root", "1"]
  end

  config.vm.provision :chef_solo do |chef|

    chef.add_recipe "meteor_windows"

    chef.json = {
      :nodejs => {
        :install_method => "package",
        :npm => "1.3.23"
      },
      :meteor_windows => {
        :apps => [
          "mymeteorapp"
        ]
      }
    }
  end
end