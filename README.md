## This is a meta repository for developers who want to work on writing lessons.

### General

To get started, configure git with ssh access, 'user.name', and 'user.email' on your local machine. 

Clone this repository:

~~~ bash
git clone git@github.com:Southampton-RSG-Training/TrainingProjects.git
~~~

Optional: Open configure remotes and remove lessons/templates that you will not want to work on.

Run the shell script configure-remotes.sh. This clones (or pulls) listed training projects into folders and 
sets up the template remotes. In addition, it also downloads the Vagrant Build directory that has a virtual machine 
local build using vagrant.

~~~ bash
bash ./configure-remotes.sh
~~~

We use Vagrant with the provider VirtualBox provisioned using Ansible. This automatically creates an inventory suitable
fo launching further jobs. However, deploying a lesson is a one liner

The following command will build the vagrant machine and run the jekyll server with auto-reload.

~~~bash
bash ./build-local.sh <local path to lesson>
~~~

e.g. to build the python lesson 

~~~bash
bash ./build-local.sh Lessons/python-novice
~~~

_Please note the first time you run this script the vm is provisioned and this takes 10-20 minutes. Following builds are 
much faster._


The script snapshots the VM, runs lesson server untill reciving ctrl-c, and finally pops the snapshot to restore the VM 
to a 'clean' ready state. so another lesson can be built.

Access the site in a browser using the following:
~~~
http://localhost/8124/
~~~

**Do not try to build multiple lessons simultaneously, I havent tested it and bad things will happen. I _may_ look into 
this in the future.**

## Common issues 
### _contributions welcome via issues or PRs_

Problems:
If vagrant times out/hangs on ssh on an initial build
or,
If the virtual machine stops working
then,

~~~bash
cd VagrantBuild
vagrant destroy
vagrant up
~~~

If you want to poke at the VM:

~~~bash
cd VagrantBuild
vagrant ssh
~~~

## Platform specific notes, 
### _contributions welcome via issues or PRs_

### Windows
#### Warning for WSL users: Currently shared folders are not supported in WSL. WSL is currently not supported see below.

On prompt allow access to public and private networks.

### Mac

### Linux

### WSL

This is unsupported, PR welcome if fixes are available.

Install vagrant on WSL using apt/yum/snap/from-source

Vagrant Documentation on WSL:
[https://www.vagrantup.com/docs/other/wsl](https://www.vagrantup.com/docs/other/wsl)

GitHub issue from 2020 with a soulution?!
[https://github.com/hashicorp/vagrant/issues/11705](https://github.com/hashicorp/vagrant/issues/11705)