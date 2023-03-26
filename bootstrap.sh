#!/usr/bin/sh

ROOT_TARGET=$1

cat /etc/os-release

APK_REPO_URL=$(head -n 1 /etc/apk/repositories)

apk add apk-tools-static
apk.static \
  --arch $(uname -m) \
  -X $APK_REPO_URL \
  -U \
  --allow-untrusted \
  --root $ROOT_TARGET \
  --initdb add alpine-base

echo "Have serial console"
sed -i '/\#ttyS0::respawn:\/sbin\/getty -L ttyS0 115200 vt100/a\ttyAMA0::respawn:\/sbin\/getty -L 0 ttyAMA0 vt100' $ROOT_TARGET/etc/inittab

echo "Deploy fstab"
install -D data/fstab $ROOT_TARGET/etc/fstab
mkdir $ROOT_TARGET/boot

echo "Deploy network config"
install -D data/network/interfaces $ROOT_TARGET/etc/network/interfaces

echo "alpine-arm64" > $ROOT_TARGET/etc/hostname

echo "Change Root"
chroot $ROOT_TARGET rc-update add syslog boot
chroot $ROOT_TARGET rc-update add networking
chroot $ROOT_TARGET rc-update add ntpd
