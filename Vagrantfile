# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "precise32"

  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.network  :private_network, ip: "10.11.12.13"

  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|

    chef.add_recipe "git"
    chef.add_recipe "nodejs"
    chef.add_recipe "nodejs::npm"
    #chef.add_recipe "meteor"

    #chef.json = {
    #  "meteor" => {
    #    "install_url" => "https://install.meteor.com",
    #    "install_mongodb" => true,
    #    "install_meteorite" => true,
    #    "create_meteor_user" => true
    #  }
    #}
  end
end