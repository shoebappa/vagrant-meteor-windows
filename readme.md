# Meteor on Windows with Vagrant

These are the steps I use to run meteor on windows by provisioning a virtualized Linux box.  I find this better for running just about any dev environment on Windows if you have the Ram and CPU cores.  Usually these Vagrant boxes are intended to be throwaways, where what's on the VM could be re-provisioned entirely from what's held in the Vagrantfile and the mapped files that will be added along side this, and other app specific deployment tools.

The instructions below will have you download and install a Virtualization tool (Virtual Box), VM Provisioner (Vagrant), which will download a Linux OS for you (280MB), and download several Chef cookbooks (scripts) to run on the provisioned VM to install the server software needed to run Meteor.  These are pretty amazing tools for setting up repeatable development environments/sandboxes for teams or personal use.  Some of the tools (Chef, Berkshelf) also translate well into production devops provisioning, but it may be a bit overkill for just getting meteor running on Windows.

## Changelog

6/2/2014 - After a few months of not supporting the latest vagrant due to some changes and uncertainty with the vagrant-berkshelf plugin.  It seems at least for now I've gotten this working with the Latest Vagrant, Virtual Box, and Vagrant Berkshelf Plugin.  Note that the --provision is no longer require because of the `run: "always"` support.

2/16/2014 - Changed the symlinked directory from {app}/.meteor to {app}/.meteor/local to help with version control.  Thanks @mmucklo for the pull request.  Made configurable with `:meteor_windows => :mount_directory`.  This change may break existing apps, so you could set that back to `.meteor`.

1/19/2014 - Updated with new require_plugin directives.  Added omnibus and vbguest plugins, which should allow this to work with more base boxes that might not have the VMWare tools and Chef already installed.

At some point Vagrant decided that running the provisioner on every `up` was no longer desired.  Since I was relying on the provisioner to mount the symlinks, you must now run `vagrant up --provision` see: https://github.com/mitchellh/vagrant/issues/2421 for details of the change on the Vagrant side.

With this change I also updated to a new base box running ubuntu 13.10.  I would assume this would need app migration, so if that's a problem, I wouldn't update vagrant / these scripts.  Feel free to try the new plugins with the old Ubuntu version, but I couldn't get it to work.

6/23/2013 - Added support for Meteorites new symlinks.  This will mount --bind each apps packages directory.

## Update

*This version has been drastically modified from earliest version.  If you used versions without the Symlinks, I would recommend using these in a new Vagrant evnironment and migrate any apps over to the new version.*

Many thanks to [Gabriel Pugliese](https://github.com/gabrielhpugliese) who provided the steps to `mount --bind` the database directories for the apps as symlinks to another area of the VM (Source: http://goo.gl/clpKa).  This helped streamline this process and allows for the utilization of the Synced Folders provided by Vagrant which allows for the use of pretty much any development tools of you pleasing to code applications locally from the Windows host machine.  The issue that this resolved is that without the symlink, MongoDB can't operate in the synced folder on Windows.  Normal symlinks also won't work, so using `mount --bind` was a great find.

## Prerequisites

Before using the Vagrant provisioning included in this repository, you will need to have Git, VirtualBox, Vagrant, and the Vagrant Berkshelf plugin installed.

### Download and Install Git

You need to have Git's cmd AND bin folders in the Windows `Path` environment variable (this is an option in the installer).  In later steps, Vagrant will utilize `ssh` binary that is installed along with Git.

http://git-scm.com/

Optionally: If you are concerned about modifying the Windows Path for Git SSH and all the other apps included there, I've found that Git Shell from GitHub for Windows http://windows.github.com/ will work intead of installing the Git client by using Git Shell in place of the sections below that say a "Windows Command Prompt".  Git Shell seems to configure a Power Shell with the appropriate tools for Git and SSH.  This also has the added benefit of the colors in the terminal.

### Download and Install VirtualBox

I ran into issues with VBox < 4.3.12

https://www.virtualbox.org/wiki/Downloads

### Download and Install Vagrant

The provided Vagrantfile is made for Vagrant >= 1.6.3

http://www.vagrantup.com/downloads.html

### Install Vagrant Plugins

Vagrant base boxes will typically have Chef and Virtual Box guest tools installed, but to expand the number of boxes, and also ensure that the latest version of chef is installed, vagrant-vbguest and vagrant-omnibus (chef) plugins are used and mus be installed.

Berkshelf http://berkshelf.com/ makes Chef provisioning in Vagrant and elsewhere a breeze by downloading the dependent cookbooks.  To utilize in Vagrant, we must install its plugin.  From a command prompt run:

```
vagrant plugin install vagrant-berkshelf --plugin-version ">= 2.0.1"
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-omnibus
```

*Note:* I had some trouble installing the newest vagrant-berkshelf plugin.  Git appearently has a non-functioning tar executable.  I had to download GNU Tar from: http://gnuwin32.sourceforge.net/packages/gtar.htm and add `C:\Program Files (x86)\GnuWin32\bin` to my PATH before where Git was.

## Provisioning

### Clone this repo's files

Open a command prompt (substitute `C:\vagrant` with the location you want to keep your vagrant files and `meteor` with the folder name for the files for this box):

```
cd C:\vagrant
git clone git://github.com/shoebappa/vagrant-meteor-windows.git meteor
```

### Optionally Configure Vagrant

The `C:\vagrant\meteor\Vagrantfile` holds some configuration options for the provisioning.  You will likely want a different name for you first meteor app than `mymeteorapp` so you will edit the following in the Vagrantfile:

```
:meteor_windows => {
  :apps => [
    "mymeteorapp"
  ]
}
```

This is an array so you could include as many meteor apps as you want, and this can be modified later and subsequent runs of Vagrant will only create apps from this array that it hadn't previously provisioned.

```
:meteor_windows => {
  :apps => [
    "mymeteorapp",
    "mymeteorapp2"
  ]
}
```

The Chef cookbook included in this repository not only runs a `mrt create mymeteorapp` or `meteor create mymeteorapp` but also needs to create a symlink for the database (MongoDB won't work in a Vagrant synced folder and neither will normal symlinks, so the Chef mount provisioner is used to create the symlink).  You're welcome to handle this complication and meteor app creation differently by leaving this array empty, but it's there is you want it.

### Provision the VM

From the Windows Command Prompt:

```
cd C:\vagrant\meteor
vagrant up
```
This will download a virtualbox image (~280MB), and then run the Chef provisioning cookbook and configures a private network IP: 10.11.12.13.  I find the private network easier to work with than Vagrant Port Forwarding.

The first vagrant up will take several minutes, but subsequent runs should be quick.

### Starting meteor

To load Vagrant's SSH Interface to the VM run from the Windows Command Prompt:

```
cd C:\vagrant\meteor
vagrant ssh
```

Then from the Vagrant SSH prompt:

```
cd /vagrant/mymeteorapp
mrt run
```

Your meteor app should be running and viewable from your Windows host box in a browser by loading `http://10.11.12.13:3000/`

`ctrl + c` should exit the meteor app and `exit` will drop you back at the Windows prompt.


## Ongoing Usage

### Editing your application

You should be able to use whatever editors you please by editing the files on your Windows host machine at `C:\vagrant\meteor\mymeteorapp\`.  The live updating features of Meteor should all still work thanks to the Vagrant synced folders and the symlink workaround.

### Adding more meteor apps

To add additional meteor applications, you will need to add the name of the app to the `Vagrantfile` :meteor_windows => :apps array and reload Vagrant from the Windows Command Prompt.  To exit the Vagrant SSH prompt type `exit`

```
cd C:\vagrant\meteor
vagrant reload
```

### Suspend Vagrant

To suspend and resume the vagrant box, use `vagrant suspend` and `vagrant resume`.

### Revision Control

Revision Control should work from the Windows side or the Linux side.  There is a symlink that Windows wouldn't see that includes the database (I would typically not version control the DB, but if that were wanted, this would need to happen in the VM)

### Backup

I would strongly recommend backing up the applications and databases from within the VM.  There are directions below on how you could connect to the VM with a tool such as SFTP Net Drive or WinSCP.

### Migrating Applications

The symlink complexity of this implementation complicates migrating an existing application.  I would recommend adding it through the `Vagrantfile` and `vagrant reload`ing in order for the Provisioning to create the apps and manage the symlinks on each load of the VM.  Then you would overlay you application files, and if necessary use a tool such as SFTP Net Drive or WinSCP (details on usage below) to replace the Database files which i would be located on the VM under `/home/vagrant/mymeteorapp/.meteor/local/db

## Optional Features and Tools

### Vagrant Chef Configuration Attributes

These are configuration options that would go in the `:meteor_windows => {}` section on the `chef.json` settings of the `Vagrantfile`

#### Meteor Apps Config (Default: mymeteorapp)

The `apps` attribute is a string array that will provision each as a mrt or meteor application and create the appropriate symlinks.

```
:meteor_windows => {
  :apps => [
    "mymeteorapp",
    "mymeteorapp2"
  ]
}
```

#### Customized Vagrantfile

The below would create apps mymeteorapp and mymeteorapp2 using meteor create instead of mrt create under the /vagrant/apps... directory with a database symlinks under /home/vagrant/apps/... and skip the meteorite install and enabling ACPI support (see below)

Look at the `repo\cookbooks\attributes\default.rb` to see the configurable options.

```
chef.json = {
  :nodejs => {
    :install_method => "package"
  },
  :meteor_windows => {
    :apps => [
      "mymeteorapp",
      "mymeteorapp2"
    ],
    :install_meteorite => false,
    :install_acpipowerbutton => true,
    :meteor_command => "meteor",
    :sync_directory => "/vagrant/apps",
    :home_directory => "/home/vagrant/apps",
    :mount_directory => ".meteor"
  }
}
```

#### ACPI Support

It was recommended on the meteor group that `vagrant halt` while claiming to gracefully shut down, might not.  In the VitrualBox guidance, it was recommended to gracefully shutdown the machine just as you would a real machine through SSH.  If you want to enable ACPI support in the VM and add a helper that will send the `VBoxManage acpipowerbutton` command to the right Vagrant Box, use the `:install_acpipowerbutton` chef.json attribute in the Vagrantfile.  The `acpipowerbutton.cmd` helper script will also be installed in your vagrant synced folder along with the `acpi-support` package on the VM.

To use from a Windows Command Prompt in the `C:\vagrant\meteor\` folder run the command `acpipowerbutton`.  Optionally if using Git Shell from the same folder run `./acpipowerbutton`

### Alternate ways of connecting to the VM and transferring files

#### Eldos SFTP Net Drive

A reasonably easy tool to connect to the VM for file transfer is Eldos SFTP Netdrive: http://www.eldos.com/sftp-net-drive/download-release.php.  This will use Vagrant's OpenSSH Key to connect so you can just connect to `10.11.12.13` on Port: `22` and Username: `vagrant` and use the Key Based Authentication and `Choose...` the vagrant SSH key located at: `C:\Users\[Your Username]\.vagrant.d\insecure_private_key`

#### Putty and WinSCP

If you would like to utilize special tools to connect to the VM such as Putty, or WinSCP, you will need to modify the Vagrant SSH Key with PuttyGen.

Download Putty and PuttyGen from http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html to SSH into the VM and to convert the Vagrant SSH Key to a Putty style ppk that can be used by Putty, WinSCP.  Once you have puttygen, load the Vagrant key found under `C:\Users\[Your Username]\.vagrant.d\insecure_private_key`, then save it back out to a ppk file (I didn't use a password for the key, but perhaps there is a reason to).

Open Putty, use IP `10.11.12.13` and port `22`, Click "Connection > Data" in the tree and put Auto-login username "vagrant", then go to "SSH > Auth" and Browse in the "Private key file" to the ppk you generated with Puttygen.  Now Go back to the main screen by clicking "Session" in the Tree, and type a relevant name in the "Saved Sessions" such as "Vagrant Meteor" and click save.  This will save the IP Address, Login Name and Key location for the next time you run Putty and you can just click the saved session.  Running this should give you a SSH Terminal to the Vagrant virtualized Linux box.
