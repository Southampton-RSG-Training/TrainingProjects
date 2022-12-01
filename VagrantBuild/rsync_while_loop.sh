# This is a terrible terrible hack because git bash cant launch a cronjob. (I'm sorry)
echo 'running the following every 5 seconds until interrupt in the main script\n'
cat tmp/rsync_task.sh | cat
while True
do
  sleep 5
  bash tmp/rsync_task.sh
done