# build-image
Build a Linux distribution based on Alpine with GitHub CI

This is mentioned in the talk [Launch the First Process in Linux System](https://www.slideshare.net/chienhungpan/launch-the-first-process-in-linux-system).

## Use the QEMU image for Example

1. Download the compressed image & checksum from the [Releases](https://github.com/starnight/build-image/releases) and verify the image with the checksum.
```sh
$ ls simple-alpine-qemu_aarch64.img.xz*
simple-alpine-qemu_aarch64.img.xz  simple-alpine-qemu_aarch64.img.xz.sha512
$ sha512sum -c simple-alpine-qemu_aarch64.img.xz.sha512
simple-alpine-qemu_aarch64.img.xz: OK
```
2. Decompress the image as the RAW disk image.
```sh
$ unxz simple-alpine-qemu_aarch64.img.xz
$ ls simple-alpine-qemu_aarch64.img
simple-alpine-qemu_aarch64.img
```
3. List the partitions of the RAW disk image.
```sh
$ fdisk -l simple-alpine-qemu_aarch64.img
Disk simple-alpine-qemu_aarch64.img: 256 MiB, 268435456 bytes, 524288 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x69aba5f7

Device                          Boot  Start    End Sectors  Size Id Type
simple-alpine-qemu_aarch64.img1 *      2048 206847  204800  100M  c W95 FAT32 (LBA)
simple-alpine-qemu_aarch64.img2      206848 524287  317440  155M 83 Linux
```
  The 1st partition is the boot partition, but not used.  The 2nd partition holds Root Filesystem.  The layout is according to the platform and case by case actually.
4. Run a QEMU aarch64 VM with the RAW disk image and the built kernel image.
```
$ qemu-system-aarch64 \
	-smp 2 \
	-M virt \
	-cpu cortex-a57 \
	-m 1G \
	-kernel <built aarch64 kernel> \
	--append "console=ttyAMA0 root=/dev/vda2 rw rootfstype=ext4" \
	-hda simple-alpine-qemu_aarch64.img \
	-serial stdio
```

The RISC-V 64 bits image can be used in the same way:
```
$ qemu-system-riscv64 -smp 4 \
    -M virt \
    -m 2G \
    -kernel <built riscv64 kernel> \
    -append "root=/dev/vda2 rw rootfstype=ext4" \
    -drive file=simple-alpine-qemu_riscv64.img,format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -netdev user,id=eth0 \
    -device virtio-net-device,netdev=eth0 \
    -serial stdio
```
