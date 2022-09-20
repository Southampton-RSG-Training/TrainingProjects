
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

# do the RSG python/R pre build
vagrant ssh -c "cd /Materials/$1; pwd; bash bin/build_me.sh"
vagrant rsync-auto &
RSYNC_PID=$!
# Build the site.
vagrant ssh -c "cd /Materials/$1; bundler install; bundler exec jekyll serve --baseurl='' --host=0.0.0.0 --port=8124 --livereload --livereload-port=8125"
kill $RSYNC_PID

# Restore the vm to the snapshot
vagrant snapshot pop


