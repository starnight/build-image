#!/bin/sh

ROOT_TARGET="target/"

cat /etc/os-release

APK_REPO_URL=$(cat /etc/apk/repositories | sed -e "s/^/-X /g" | tr '\n' ' ')

if [ "$BOOTSTRAP_PACKAGES_FILE" == "" ]
then
  BOOTSTRAP_PACKAGES_FILE="bootstrap.packages"
fi

apk add apk-tools-static
apk.static \
  --arch $(uname -m) \
  $APK_REPO_URL \
  -U \
  --allow-untrusted \
  --root $ROOT_TARGET \
  --initdb add $(cat ${BOOTSTRAP_PACKAGES_FILE} | tr '\n' ' ')

echo "Have serial console"
PATTERN_STR='\#ttyS0::respawn:\/sbin\/getty -L ttyS0 115200 vt100'
case $(uname -m) in
  aarch64)
    APPEND_STR='\ttyAMA0::respawn:\/sbin\/getty -L 0 ttyAMA0 vt100' ;;
  riscv64)
    APPEND_STR='\ttyS0::respawn:\/sbin\/getty -L ttyS0 115200 vt100' ;;
  *)
    APPEND_STR=''
esac
sed -i "/${PATTERN_STR}/a${APPEND_STR}" $ROOT_TARGET/etc/inittab

echo "Deploy fstab"
install -D data/fstab $ROOT_TARGET/etc/fstab
mkdir $ROOT_TARGET/boot

echo "Deploy network config"
install -D data/network/interfaces $ROOT_TARGET/etc/network/interfaces

echo "alpine-$(uname -m)" > $ROOT_TARGET/etc/hostname

echo "Prepare APK repository list"
cp /etc/apk/repositories $ROOT_TARGET/etc/apk/repositories

echo "Change Root"
# Enable services
chroot $ROOT_TARGET rc-update add syslog boot
chroot $ROOT_TARGET rc-update add networking
chroot $ROOT_TARGET rc-update add ntpd
