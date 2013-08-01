Graylog2 Cookbook
==================

This repository contains the graylog2 cookbook, as well as example roles and files for testing the cookbook.

Librarian config
-------
To use this cookbook with librarian-chef, refer to the sample Cheffile in the examples directory.

Testing with Vagrant
-------

This will setup a VM with a working Graylog2 installation.

  1) Install vagrant

    gem install vagrant

  2) Install VirtualBox

  3) Launch & provision VM

    cd examples
	vagrant up    

Enjoy your running Graylog2 instance (load http://127.0.0.1:8080 in a browser to  
access Graylog2). Also, check out 'vagrant ssh' to log in to VM and 'vagrant 
provision' to kick of the chef run again).  If you want to edit any of the Chef 
attributes for Graylog2 configuration, do so in the Vagrantfile.

Contributing
------------

Please contribute updates, additions or documentation changes.  If you don't hear back briefly,
feel free to pester continuously.

### Repo contributors

  * jbz
  * nstielau
  * portertech
  * agoddard
  * spazm
