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

if [ "$1" = "" ]; then
    echo "First argument must be path to lesson to build"
    exit
fi

echo "Building and deploying $1 to Vagrant"

cd VagrantBuild

vagrant_state=$(vagrant status --machine-readable | grep ',state,')
IFS=',' read -ra state_array <<< $vagrant_state

if [ "${state_array[3]}" != "running" ];
then
  echo "Vagrant not running, bringing up, if unprovisioned this may take a few minutes"
  vagrant up
fi

# Gather information about the vagrant instance
vagrant ssh-config > .ssh_info.tmp

lessonbox_ip=$(grep 'HostName' .ssh_info.tmp | cut -d " " -f 4)
lessonbox_port=$(grep 'Port' .ssh_info.tmp | cut -d " " -f 4)
lessonbox_user=$(grep -w 'User' .ssh_info.tmp | cut -d " " -f 4)


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
vagrant ssh -c "rm ~/Materials/$ep_path*; rm ~/Materials/$ep_path.gitkeep"

if [[ $simple_os_type == "WIN" ]]; then
    # Windows
    # use a template to create a task to pass into the scheduler
    # Windows run this hack
    echo "rsync -r $abs_path/ $lessonbox_user@$lessonbox_ip:~/Materials/$ep_path -e 'ssh -p $lessonbox_port -i .vagrant/machines/LessonBox/virtualbox/private_key'" > tmp/rsync_task.sh
    bash rsync_while_loop.sh & >> tmp/rsync_log.txt
    pid_for_hack=$!
    echo we are going to kill $pid_for_hack later
else
  # Sane OSes, start an rsync cronjob to run:
  echo "*/5 * * * * * rsync -r $abs_path/ $lessonbox_user@$lessonbox_ip:~/Materials/$ep_path -e 'ssh -p $lessonbox_port -i .vagrant/machines/LessonBox/virtualbox/private_key'" > tmp/rsync_task.sh
  crontab -e tmp/rsync_task.sh
fi

sleep 10
# Do the RSG python/R pre build, the sed command is required to make deployment from windows work.
echo ssh -c "cd ~/Materials/$1; pwd; sed -i 's/\r$//' bin/build_me.sh; bash bin/build_me.sh"
vagrant ssh -c "cd ~/Materials/$1; pwd; sed -i 's/\r$//' bin/build_me.sh; bash bin/build_me.sh"

## Build the site.
echo ssh -c "cd ~/Materials/$1; bundler install; bundler exec jekyll serve --baseurl='' --host=0.0.0.0 --port=8124 --livereload --livereload-port=8125"
vagrant ssh -c "cd ~/Materials/$1; bundler install; bundler exec jekyll serve --baseurl='' --host=0.0.0.0 --port=8124 --livereload --livereload-port=8125"


read -p 'Press any key to bring the test server down restore the snapshot'

# Kill the reload
if [[ $simple_os_type == "WIN" ]]; then
    # In windows we need to kill the hack
    kill $pid_for_hack
else
    # In sane OS we need to kill the cronjob
    crontab -r rsync_task.sh
fi

rm .ssh_info.tmp tmp/rsync_task.sh tmp/rsync_log.txt

# Restore the vm to the snapshot
vagrant snapshot pop