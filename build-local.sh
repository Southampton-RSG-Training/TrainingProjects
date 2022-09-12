
echo "Building and deploying $1 to Vagrant"

cd VagrantBuild

# Bring up the vm and snapshot it
vagrant up
vagrant snapshot push



# Restore the vm to the snapshot
vagrant snapshot pop


