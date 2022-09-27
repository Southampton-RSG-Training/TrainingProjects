echo "Building and deploying $1 to Vagrant"

cd VagrantBuild

vagrant_state=$(vagrant status --machine-readable | grep ',state,')
IFS=',' read -ra state_array <<< $vagrant_state

if [ "${state_array[3]}" != "running" ];
then
  echo "Vagrant not running, bringing up, if unprovisioned this may take a few minutes"
  vagrant up
fi

# Snapshot the VM blank state to restore later
vagrant snapshot push

# Make sure files are in sync
vagrant rsync-auto &
RSYNC_PID=$!

# Do the RSG python/R pre build, the sed command is required to make deployment from windows work.
vagrant ssh -c "cd /Materials/$1; pwd; sed -i 's/\r$//' bin/build_me.sh; bash bin/build_me.sh"

# Build the site.
vagrant ssh -c "cd /Materials/$1; bundler install; bundler exec jekyll serve --baseurl='' --host=0.0.0.0 --port=8124 --livereload --livereload-port=8125"

read -p 'Press any key to start file cleanup'

echo "" > .gitmodules
rm setup.md
rm -r _site/ collections/ _includes/rsg/*-lesson/ _includes/ submodules/

read -p 'Press any key to end rsync and restore the snapshot'

kill $RSYNC_PID

# Restore the vm to the snapshot
vagrant snapshot pop


