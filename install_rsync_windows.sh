# If this stops working give up and install linux (not WSL)
# https://gist.github.com/hisplan/ee54e48f17b92c6609ac16f83073dde6?permalink_comment_id=3605244#gistcomment-3605244
mkdir -p install_rsync
cd install_rsync
curl http://repo.msys2.org/msys/x86_64/rsync-3.2.3-1-x86_64.pkg.tar.zst --output rsync-3.2.3-1-x86_64.pkg.tar.zst
curl http://repo.msys2.org/msys/x86_64/libxxhash-0.8.0-1-x86_64.pkg.tar.zst --output libxxhash-0.8.0-1-x86_64.pkg.tar.zst
curl http://repo.msys2.org/msys/x86_64/liblz4-1.9.3-1-x86_64.pkg.tar.zst --output liblz4-1.9.3-1-x86_64.pkg.tar.zst
curl http://repo.msys2.org/msys/x86_64/libzstd-1.4.8-1-x86_64.pkg.tar.zst --output libzstd-1.4.8-1-x86_64.pkg.tar.zst

zstd -d *.tar.zst

tar -xf rsync-3.2.3-1-x86_64.pkg.tar
tar -xf libxxhash-0.8.0-1-x86_64.pkg.tar
tar -xf liblz4-1.9.3-1-x86_64.pkg.tar
tar -xf libzstd-1.4.8-1-x86_64.pkg.tar


# This is the path to the git bash install
gitpath="/c/Program Files/Git"


for file in $(find usr -type f )
do
  mkdir -p "$gitpath/$(dirname $file)"
  cp $file "$gitpath/$file"
done
