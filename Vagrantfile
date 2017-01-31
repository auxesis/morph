# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # local: A local machine that mimics a production deployment

  # All VMs are based on Ubuntu Precise 64 bit
  config.vm.box = "ubuntu"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.define "local" do |local|
    local.vm.network :private_network, ip: "192.168.11.2"
    local.vm.hostname = "dev.morph.io"
    local.vm.network :forwarded_port, guest: 22, host: 2200
    local.vm.network :forwarded_port, guest: 4443, host: 4443
    local.vm.synced_folder ".", "/vagrant", disabled: true

    local.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end

    local.vm.provision :ansible do |ansible|
      ansible.playbook = "provisioning/playbook.yml"
      ansible.verbose = 'v'
      ansible.groups = {
        "development" => ["local"]
      }
    end
  end

  config.vm.define 'aws' do |aws|
    aws.vm.hostname = 'dev.morph.io'
    aws.vm.synced_folder '.', '/vagrant', disabled: true

    aws.vm.box = 'dummy'
    aws.vm.provider 'aws' do |v, override|
      v.access_key_id     = lookup('AWS_ACCESS_KEY_ID')
      v.secret_access_key = lookup('AWS_SECRET_ACCESS_KEY')
      v.keypair_name      = lookup('KEYPAIR_NAME')
      v.ami               = lookup('AMI_ID', :default => 'ami-65308205')
      v.instance_type     = lookup('INSTANCE_TYPE', :default => 'm3.medium')
      v.region            = lookup('AWS_REGION', :default => 'us-west-2')
      v.tags              = { 'Name' => 'morph_dev' }

      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = File.expand_path(lookup('KEYPAIR_NAME') + '.pem')
    end

    aws.vm.provision :ansible do |ansible|
      ansible.playbook = 'provisioning/playbook.yml'
      ansible.verbose = 'v'
      ansible.groups = {
        'development' => ['local']
      }
      ansible.raw_ssh_args = [
        "-o UserKnownHostsFile=/dev/null",
        "-o CheckHostIP=no",
        "-o StrictHostKeyChecking=no",
        "-o ControlMaster=yes",
        "-o ControlPath=~/%%h‐%%r",
        "-o ControlPersist=30m"
      ]

    end
  end
end

def lookup(envvar, opts={})
  return ENV[envvar] if ENV[envvar]
  return opts[:default] if opts[:default]
  raise ArgumentError, "Error: must supply #{envvar}"
end
