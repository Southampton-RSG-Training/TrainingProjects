# If this stops working give up and install linux (not WSL)
# https://gist.github.com/hisplan/ee54e48f17b92c6609ac16f83073dde6?permalink_comment_id=3605244#gistcomment-3605244
mkdir -p install_rsync
cd install_rsync
# If issues are encountered check the repo https://repo.msys2.org/msys/x86_64/ and check version numbers
curl -L http://repo.msys2.org/msys/x86_64/rsync-3.2.3-1-x86_64.pkg.tar.zst --output rsync.pkg.tar.zst
curl -L http://repo.msys2.org/msys/x86_64/libxxhash-0.8.0-1-x86_64.pkg.tar.zst --output libxxhash.pkg.tar.zst
curl -L http://repo.msys2.org/msys/x86_64/liblz4-1.9.3-1-x86_64.pkg.tar.zst --output liblz4.pkg.tar.zst
curl -L http://repo.msys2.org/msys/x86_64/libzstd-1.5.2-2-x86_64.pkg.tar.zst --output libzstd.pkg.tar.zst

# Set the location of your zstd if you have locally installed zstd (the following is correct if it is placed in program
# files)
# /c/Program\ Files/zstd-v1.5.2-win64/zstd-v1.5.2-win64/zstd
/c/Program\ Files/zstd-v1.5.2-win64/zstd-v1.5.2-win64/zstd -d *.tar.zst

tar -xf rsync.pkg.tar
tar -xf libxxhash.pkg.tar
tar -xf liblz4.pkg.tar
tar -xf libzstd.pkg.tar


# This is the path to the git bash install
gitpath="/c/Program Files/Git"


#for file in $(find usr -type f )
#do
#  mkdir -p "$gitpath/$(dirname $file)"
#  cp $file "$gitpath/$file"
#done
