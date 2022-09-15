
echo "Building and deploying $1 to Vagrant"

cd VagrantBuild

vagrant_state=$(vagrant status --machine-readable | grep ',state,')
IFS=',' read -ra state_array <<< $vagrant_state

if [ ${state_array[3]} != "running" ];
then
  echo "Vagrant not running, bringing up, if unprovisioned this may take a few minutes"
  vagrant up
fi

# Snapshot the VM blank state to restore later
vagrant snapshot push


vagrant ssh -c ""

# Restore the vm to the snapshot
vagrant snapshot pop


