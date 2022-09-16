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

For users familiar with vagrant/have vagrant installed simply run else see the platform specific documentation below.

~~~bash
cd VagrantBuild
vagrant up
~~~

Vagrant uses the provider VirtualBox and is provisioned using Ansible. This automatically creates an inventory suitable 
fo launching further jobs. 

The script build-local.sh snapshots the VM runs Ansible to build and serve a lesson then when commanded kills the lesson
server and finally pops the snapshot to restore the VM to a 'clean' ready state.

Access the server at 
~~~
http://localhost/8124/
~~~


## Platform specific notes, contributions welcome via issues or PRs

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