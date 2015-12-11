#!/bin/bash -x
# ubuntu-sdk-get
# sudo ./ubuntu-sdk-get.sh alan

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit
fi

nonrootuser=$1
schrootdir="/var/lib/schroot/chroots"
prefix="ubuntu-sdk"
release="vivid"
arch="amd64"

chrootlongname=$prefix-$release-$arch
full_path=$schrootdir/$chrootlongname
# might not be needed
mkdir -p $full_path


export http_proxy="http://192.168.1.2:8000/"
mirror="http://de.archive.ubuntu.com/ubuntu/"
includes="software-properties-common"

debootstrap --include $includes \
            --arch $arch \
            $release \
            $full_path \
            $mirror
if [ "$?" == "0" ]; then
  echo "Successfully made chroot."

cat << EOF > /etc/schroot/chroot.d/ubuntu-sdk.conf
[$chrootlongname]
description=Ubuntu SDK $release for $arch
directory=$full_path
root-users=root,$nonrootuser
type=directory
users=root,$nonrootuser
EOF

cat << EOF > $full_path/etc/apt/sources.list
deb $mirror $release main restricted universe multiverse
deb $mirror $release-updates main restricted universe multiverse
deb-src $mirror $release main restricted universe multiverse
deb-src $mirror $release-updates main restricted universe multiverse
EOF

schroot -c $chrootlongname -u root -- /usr/bin/add-apt-repository ppa:ubuntu-sdk-team/ppa -y
schroot -c $chrootlongname -u root -- /usr/bin/apt-get update
schroot -c $chrootlongname -u root -- /usr/bin/apt-get install  -y --force-yes ubuntu-sdk cmake

# Create desktop file
cat << EOF > ~/.local/share/applications/ubuntu-sdk-ide.desktop
[Desktop Entry]
Exec=xhost + local: && schroot -c $chrootlongname -- sh -c export DISPLAY=:0.0 /usr/ubuntu-sdk-ide/bin/qtcreator -platformtheme appmenu-qt5 %F
Icon=$full_path/usr/share/icons/ubuntu-sdk-ide.png && xhost -
Type=Application
Terminal=false
Name=Chroot Ubuntu SDK IDE
GenericName=Integrated Development Environment
MimeType=text/x-c++src;text/x-c++hdr;text/x-xsrc;application/x-designer;application/vnd.nokia.qt.qmakeprofile;application/vnd.nokia.xml.qt.resource;application/x-qmlproject;
Categories=Qt;Development;IDE;
InitialPreference=9
Keywords=IDE;Ubuntu SDK IDE;buntu SDK;SDK;Ubuntu Touch;Qt Creator;Qt
EOF

echo Icon should be on the menu

echo The following commands will launch the Ubuntu SDK
echo xhost + local:
echo "schroot -c $chrootlongname -- sh -c export DISPLAY=:0.0 && /usr/ubuntu-sdk-ide/bin/qtcreator -platformtheme appmenu-qt5"
else
  echo "Creating chroot failed."
fi
