# Get the OS type or fall over
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # ...
      simple_os_type="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
      # Mac OSX
      simple_os_type="OSX"
elif [[ "$OSTYPE" == "cygwin" ]]; then
      # POSIX compatibility layer and Linux environment emulation for Windows
      simple_os_type="WIN"
elif [[ "$OSTYPE" == "msys" ]]; then
      # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
      simple_os_type="WIN"
elif [[ "$OSTYPE" == "win32" ]]; then
      # I'm not sure this can happen.
      simple_os_type="WIN"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
      # ...
      simple_os_type="linux"
else
      echo "Unknown OS, $OSTYPE, please review lines 1 to 14"
fi

echo "building on $OSTYPE, using simple type $simple_os_type"

if [ "$1" = "" ]; then
    echo "First argument must be path to lesson to build"
    exit
fi

echo "Dry run of $1 to Vagrant"

cd VagrantBuild

vagrant_state=$(vagrant status --machine-readable | grep ',state,')
IFS=',' read -ra state_array <<< $vagrant_state

if [ "${state_array[3]}" != "running" ];
then
  echo "Vagrant not running, bringing up, if unprovisioned this may take a few minutes"
  echo vagrant up
fi

# Gather information about the vagrant instance
echo vagrant ssh-config > .ssh_info.tmp

echo lessonbox_ip=$(grep 'HostName' .ssh_info.tmp | cut -d " " -f 4)
echo lessonbox_port=$(grep 'Port' .ssh_info.tmp | cut -d " " -f 4)
echo lessonbox_user=$(grep -w 'User' .ssh_info.tmp | cut -d " " -f 4)


echo vagrant plugin install vagrant-scp

# Snapshot the VM blank state to restore later
echo vagrant snapshot push

echo "matching path: $1"
# match upto the first fwd slash
re="^([^/]+)(/)"
if [[ $1 =~ $re ]]; then
  containing_dir=${BASH_REMATCH[1]};
  echo $containing_dir
fi

echo ssh -c "mkdir -p ~/Materials/$containing_dir"
# Copy the files required to build the lesson to the vm.
echo scp ../$1 LessonBox:~/Materials/$1

# get absolute path to the input episodes
get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# workshops dont need to have a live reload
if [[ $containing_dir == "Lessons" ]]; then
  ep_path="$1_episodes/"
  rsync_on=1
else
  rsync_on=0
fi

echo "rsync status $rsync_on"

if [[ $rsync_on == 1 ]]; then
  abs_path=$(get_abs_filename ../$ep_path)

  # remove files from intended mount point
  echo vagrant ssh -c "rm ~/Materials/$ep_path*; rm ~/Materials/$ep_path.gitkeep"

  echo mkdir -p tmp

  if [[ $simple_os_type == "WIN" ]]; then
      # Windows
      # use a template to create a task to pass into the scheduler
      # Windows run this hack
      echo echo "rsync -r $abs_path/ $lessonbox_user@$lessonbox_ip:~/Materials/$ep_path -e 'ssh -p $lessonbox_port -i .vagrant/machines/LessonBox/virtualbox/private_key'" > tmp/rsync_task.sh
      echo bash rsync_while_loop.sh & >> tmp/rsync_log.txt
      echo pid_for_hack=$!
      echo echo we are going to kill $pid_for_hack later
  else
    # cron can't run every 5 seconds so we will switch to inotify
    # Sane OSes, start an file watch using inotify and on change run:
    echo rsync_command="rsync -r $abs_path/ $lessonbox_user@$lessonbox_ip:~/Materials/$ep_path -e 'ssh -p $lessonbox_port -i .vagrant/machines/LessonBox/virtualbox/private_key'"
    echo rsync -r $abs_path/ $lessonbox_user@$lessonbox_ip:~/Materials/$ep_path -e 'ssh -p $lessonbox_port -i .vagrant/machines/LessonBox/virtualbox/private_key'
    echo echo "fswatch -0 -r -i -o '.*\.md\$' --event 14 $abs_path/ | xargs -0 -n 1 -I {} $rsync_command" > tmp/fswatch_task.sh
    echo bash tmp/fswatch_task.sh &
    echo pid_for_fswatch=$!
    echo echo we will kill $pid_for_fswatch later
  fi
fi

echo sleep 10

# Do the RSG python/R pre build, the sed command is required to make deployment from windows work.
echo vagrant ssh -c "cd ~/Materials/$1; pwd; sed -i 's/\r$//' bin/build_me.sh; bash bin/build_me.sh"

## Build the site.
echo vagrant ssh -c "cd ~/Materials/$1; bundler install; bundler exec jekyll serve --baseurl='' --host=0.0.0.0 --port=8124 --livereload --livereload-port=8125"


echo read -p 'Press any key to bring the test server down restore the snapshot'

if [[ $rsync_on == 1 ]]; then
  # Kill the reload
  if [[ $simple_os_type == "WIN" ]]; then
      # In windows we need to kill the hack
      echo kill $pid_for_hack
  else
      # In sane OS we need to kill the watch
      echo kill $pid_for_fswatch
  fi
  echo rm tmp/rsync_task.sh tmp/rsync_log.txt tmp/fswatch_task.sh
fi

echo rm .ssh_info.tmp
echo rmdir tmp

# Restore the vm to the snapshot
echo vagrant snapshot pop