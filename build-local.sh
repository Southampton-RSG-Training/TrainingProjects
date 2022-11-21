echo "Building and deploying $1 to Vagrant"

cd VagrantBuild

vagrant_state=$(vagrant status --machine-readable | grep ',state,')
IFS=',' read -ra state_array <<< $vagrant_state

if [ "${state_array[3]}" != "running" ];
then
  echo "Vagrant not running, bringing up, if unprovisioned this may take a few minutes"
  vagrant up
fi

vagrant plugin install vagrant-scp

# Snapshot the VM blank state to restore later
vagrant snapshot push

echo "matching path: $1"
# match upto the first fwd slash
re="^([^/]+)(/)"
if [[ $1 =~ $re ]];
then
  containing_dir=${BASH_REMATCH[1]};
  echo $containing_dir
fi



echo ssh -c "mkdir -p ~/Materials/$containing_dir"
vagrant ssh -c "mkdir -p ~/Materials/$containing_dir"
# Copy the files required to build the lesson to the vm.
echo scp ../$1 LessonBox:~/Materials/$1
vagrant scp ../$1 LessonBox:~/Materials/$1

ep_path="$1_episodes/"

# get absolute path to the input episodes
get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}
abs_path=$(get_abs_filename ../$ep_path)

# remove files from intended mount point
vagrant ssh -c "rm ~/Materials/$ep_path/*; rm ~/Materials/$ep_path/.gitkeep"
vagrant ssh -c "sudo sshfs -o allow_other,default_permissions 10.0.2.2:~/$abs_path ~/Materials/$ep_path"
#vagrant rsync ../$1_episodes/ LessonBox:~/Materials/$1_episodes/

# Do the RSG python/R pre build, the sed command is required to make deployment from windows work.
echo ssh -c "cd ~/Materials/$1; pwd; sed -i 's/\r$//' bin/build_me.sh; bash bin/build_me.sh"
vagrant ssh -c "cd ~/Materials/$1; pwd; sed -i 's/\r$//' bin/build_me.sh; bash bin/build_me.sh"

# Build the site.
echo ssh -c "cd ~/Materials/$1; bundler install; bundler exec jekyll serve --baseurl='' --host=0.0.0.0 --port=8124 --livereload --livereload-port=8125"
vagrant ssh -c "cd ~/Materials/$1; bundler install; bundler exec jekyll serve --baseurl='' --host=0.0.0.0 --port=8124 --livereload --livereload-port=8125"

read -p 'Press any key to start file cleanup'

echo "" > .gitmodules
#rm setup.md
#rm -r _site/ collections/ _includes/rsg/*-lesson/ _includes/ submodules/

read -p 'Press any key to restore the snapshot'

# Restore the vm to the snapshot
vagrant snapshot pop


