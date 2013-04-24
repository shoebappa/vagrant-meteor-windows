# Meteor on Windows with Vagrant

These are the steps I use to run meteor on windows by provisioning a virtualized Linux box.  I find this better for running just about any dev environment on Windows if you have the Ram and CPU cores.  Usually these Vagrant boxes are intended to be throwaways, where what's on the VM could be re-provisioned entirely from what's held in the Vagrantfile and the mapped files that will be added along side this, and other app specific deployment tools.

The instructions below will have you download and install a Virtualization tool (Virtual Box), VM Provisioner (Vagrant), which will download a Linux OS for you (280MB), and download several Chef cookbooks (scripts) to run on the provisioned VM to install the server software needed to run Meteor.  These are pretty amazing tools for setting up repeatable development environments/sandboxes for teams or personal use.  Some of the tools (Chef, Berkshelf) also translate well into production devops provisioning, but it may be a bit overkill for just getting meteor running on Windows.

## Download and Install VirtualBox

https://www.virtualbox.org/wiki/Downloads

## Download and Install Vagrant

The provided Vagrantfile is made for Vagrant >= 1.1

http://downloads.vagrantup.com/

## Install Berkshelf Vagrant Plugin

Berkshelf http://berkshelf.com/ is awesome, and makes the Chef provisioning in Vagrant and elsewhere a breeze by downloading the dependent cookbooks.  From a command prompt run:

```
vagrant plugin install vagrant-berkshelf
```

## Place this repo's files

Place the files here in a folder under wherever you want to keep your Vagrant configs, such as `C:\vagrant\meteor`

## Provision the VM

From your command prompt at `C:\vagrant\meteor\` run:

```
vagrant up
```

This will download a virtualbox image (~280MB), and then run the provisioning to configure a private network IP: 10.11.12.13.  I find this easier to work with than Vagrant Port Forwarding.

## Create an SSH Key to connect to the VM

Download Putty and PuttyGen from http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html to SSH into the VM and to convert the Vagrant SSH Key to a Putty style ppk that can be used by Putty, WinSCP, and Eldos SFTP Net Drive.  Once you have puttygen, load the Vagrant key found under `C:\Users\[Your Username]\.vagrant.d\insecure_private_key`, then save it back out to a ppk file (I didn't use a password for the key, but perhaps there is a reason to).

Open Putty, use IP `10.11.12.13` and port `22`, Click "Connection > Data" in the tree and put Auto-login username "vagrant", then go to "SSH > Auth" and Browse in the "Private key file" to the ppk you generated with Puttygen.  Now Go back to the main screen by clicking "Session" in the Tree, and type a relevant name in the "Saved Sessions" such as "Vagrant Meteor" and click save.  This will save the IP Address, Login Name and Key location for the next time you run Putty and you can just click the saved session.  Running this should give you a SSH Terminal to the Vagrant virtualized Linux box.

## Install Meteor to the VM

There is a Meteor cookbook, but I couldn't get it to run, giving some GZip Error.  So if you use Putty to SSH into the Vagrant Box and run the meteor install script:

```
curl https://install.meteor.com | sh
```

Create a directory for your new app and and run meteor create:

```
meteor create ~/my_cool_app
cd ~/my_cool_app
meteor
```
You should be able to load this from you windows host by browsing to `http://10.11.12.13:3000/`

## Mount a drive to the VM to edit files there

Unfortunately the default Vagrant drive mapping in windows will not work, if you try to store your meteor files in `C:\vagrant\meteor` and run this, the MongoDB that gets stored along with the app, and Mongo doesn't like to be run with the way the VirtualBox file shares work.  You could use Samba, or run Mongo Separately, but I find the SFTP drive mapping to be fine, so I use the Eldos SFTP Net Drive free version http://www.eldos.com/sftp-net-drive/download-release.php. 

Once I installed SFTP Net Drive, I just used IP `10.11.12.13`, port `22`, username: vagrant, Key Based and pointed to the Puttygen created ppk key, and chose a drive letter (I did V for Vagrant).  This defaults to the home directory, which works for meteor if you run it from ~.  This should give you a mounted Drive to windows from which you can edit files from windows tools, and they should live reload to meteor.

## Suspend Vagrant

To suspend and resume the vagrant box, use `vagrant suspend` and `vagrant resume`.

