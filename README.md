# This is a meta repository for developers who want to work on writing/developing lessons.


## Overview

This repo contains scripts that download a set of the training repositories developed in the GitHub Organisation 
Southampton-RSG-Training. 

The initial shell script configure-remotes.sh clones and sorts each of the lesson, 
workshop-test, and templates this takes some time and requires a significant amount of space ~7Gb.

The second script is used to create a live server in a Vagrant VM. This opens vm and runs jekyll serve to create a 
server with live reload this means one can edit the documents live and see the updates in 'real time'. This requires
Vagrant and Virtualbox present on the host system, installation details are provided in 'VagrantBuild/README.md'.

Whilst care has been taken to create a set of tools that work on windows the experience is much better on MacOS and 
Linux. 

### Before you start

You will require the following software. 

- A terminal (bash)
- Vagrant
- Rsync*
- FSwatch*
- Git
- An IDE (IntelliJ recommended for templating workflow)

*With some differences between platforms

#### Windows

Windows causes a lot of headaches by not supporting many of the 'standard' unix tools. 

Terminal: GitBash (https://gitforwindows.org)
Rsync: Requires a custom installation, see install_rsync_windows.sh
In a nutshell this downloads and extracts msys packages and dumps the executables into the git bash install.
FSwatch: Not supported as it requires GCC see install_fswatch_source.sh

#### MacOS
Git:
~~~
% xcode-select --install
~~~
FSwatch:
~~~
% brew install fswatch
~~~

#### Linux

FSWatch, please install with your preferred package manager.

## Running the Scripts

### Checkout this repo

To get started, configure git with SSH access, 'user.name', and 'user.email' on your local machine. 

For configuring SSH access see these 
[GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

Clone this repository:

~~~ bash
git clone git@github.com:Southampton-RSG-Training/TrainingProjects.git
~~~

### Download the other repos

Optional: Open configure-remotes.sh and remove lessons/templates that you will not want to work on, this helps save 
space.

Run the shell script configure-remotes.sh. This clones (or pulls) listed training projects into a preconfigured folders 
structure. It then adds the [remote template](https://github.com/Southampton-RSG-Training/lesson-template) which allows 
for efficient updating of the build scripts and other boilerplate. In addition, it also downloads the Vagrant Build 
directory that contains the tools to launch a local live update development server via a Vagrant vm. 

_Note: This can take a long time ~10 minutes and take up several Gb of space_

~~~ bash
bash ./configure-remotes.sh
~~~

### Start a live server

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


The script snapshots the VM, runs lesson server until receiving ctrl-c, and finally pops the snapshot to restore the VM 
to a 'clean' ready state. so another lesson can be built.

Access the site in a browser using the following:
~~~
http://localhost/8124/
~~~

**Do not try to build multiple lessons simultaneously, I haven't tested it and bad things will happen. I _may_ look into 
this in the future.**

# Common issues 
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