# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

# Allow host platform checks
# http://stackoverflow.com/questions/26811089/vagrant-how-to-have-host-platform-specific-provisioning-steps
module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # vagrant-hostmanager plugin is required
  unless Vagrant.has_plugin?("vagrant-hostmanager")
    raise 'vagrant-hostmanager is not installed. run: vagrant plugin install vagrant-hostmanager'
  end

  # vagrant-vbguest plugin is required
  unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vagrant-vbguest is not installed. run: vagrant plugin install vagrant-vbguest'
  end

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "dev-api.codeforkc.devel"
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.vm.network "private_network", ip: "192.168.33.11"
  config.vm.network "forwarded_port", guest: "5000", host: "5000"
  if OS.unix?
    config.vm.synced_folder "./", "/vagrant/", type: "nfs"
    config.vm.synced_folder "./", "/var/www/", type: "nfs"
  elsif OS.windows?
    config.vm.synced_folder "./", "/vagrant/", type: "smb"
    config.vm.synced_folder "./", "/var/www/", type: "smb"
  else
    raise 'Unknown host operating system. Cannot continue.'
  end
  config.vm.provider "virtualbox" do |vb|
    vb.name = "devapi"
    vb.memory = 1024
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "85"]
  end
end

