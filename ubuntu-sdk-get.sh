#!/bin/bash
# ubuntu-sdk-get

target="./ubuntu-sdk"
mirror="http://archive.ubuntu.com/ubuntu/"
arch="amd64"
release="vivid"
includes="software-properties-common"
user="sdkuser"

debootstrap --include $includes \
            --arch $arch \
            $release \
            $target \
            $mirror
if [ "$?" == "0" ]; then
  echo "Successfully made chroot."
cat << EOF > $target/etc/apt/sources.list
deb $mirror $release main restricted universe multiverse
deb $mirror $release-updates main restricted universe multiverse
deb-src $mirror $release main restricted universe multiverse
deb-src $mirror $release-updates main restricted universe multiverse
EOF
cat << EOF > $target/tmp/script.sh
#!/bin/bash
useradd -s /bin/bash -m $user
add-apt-repository -y ppa:ubuntu-sdk-team/ppa
apt-get update
apt-get install -y ubuntu-sdk
exit 0
EOF
chmod +x $target/tmp/script.sh
chroot $target /tmp/script.sh
else
  echo "Creating chroot failed."
fi
