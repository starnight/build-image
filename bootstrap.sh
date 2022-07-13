#!/usr/bin/sh

ROOT_TARGET=$1

cat /etc/os-release

apk add apk-tools-static
apk.static \
  --arch $(uname -m) \
  -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main/ \
  -U \
  --allow-untrusted \
  --root $ROOT_TARGET \
  --initdb add alpine-base
