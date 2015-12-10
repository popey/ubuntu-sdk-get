#!/bin/bash
# ubuntu-sdk-get

export http_proxy="http://192.168.1.2:8000/"
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
# Needed for Arch (and perhaps others)
export http_proxy="http://192.168.1.2:8000/"
export PATH=/sbin:/usr/sbin:/usr/local/sbin:$PATH
export LANGUAGE="en_GB.UTF-8"
echo 'LANGUAGE="en_GB.UTF-8"' >> /etc/default/locale
echo 'LC_ALL="en_GB.UTF-8"' >> /etc/default/locale
/usr/sbin/groupadd -g 19 log
/usr/sbin/useradd -s /bin/bash -m $user
/usr/bin/add-apt-repository -y ppa:ubuntu-sdk-team/ppa
/usr/bin/apt-get update
/usr/bin/apt-get install -y --force-yes ubuntu-sdk
exit 0
EOF
chmod +x $target/tmp/script.sh
chroot $target /tmp/script.sh

echo The following command will launch the Ubuntu SDK
echo sudo chroot $target su - $user -c "qtcreator"
else
  echo "Creating chroot failed."
fi
