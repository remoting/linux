#!/bin/bash
# 设置路径
WORK_DIR=~/mylinux_build
ROOTFS_DIR=$WORK_DIR/rootfs
IMG_FILE=~/mylinux_disk.img

# 1. 环境清理
rm -rf "$WORK_DIR"
rm -f "$IMG_FILE"

mkdir -p "$ROOTFS_DIR"/{bin,sbin,etc,proc,sys,dev,mnt,boot}

# 2. 构建 BusyBox RootFS
# 假设你已经有静态编译的 busybox
cp /usr/bin/busybox "$ROOTFS_DIR/bin/"
chmod +x "$ROOTFS_DIR/bin/busybox"
chroot "$ROOTFS_DIR" /bin/busybox --install -s /bin

# 准备必要的内核文件到 RootFS 的 boot 目录
cp /boot/vmlinuz-6.12.57+deb13-amd64 "$ROOTFS_DIR/boot/vmlinuz"
cp ~/initrd.img "$ROOTFS_DIR/boot/initrd.img"

# 3. 创建空白镜像文件 (例如 200MB)
dd if=/dev/zero of="$IMG_FILE" bs=1M count=200

# 4. 磁盘分区 (使用 GPT)
# 分区 1: EFI (50MB), 分区 2: Linux Root (剩余空间)
sgdisk -n 1:2048:104447 -t 1:ef00 "$IMG_FILE"    # EFI 分区
sgdisk -n 2:104448:0    -t 2:8300 "$IMG_FILE"    # Linux EXT4 分区

# 5. 格式化并写入内容
# 获取循环设备
LOOP_DEV=$(losetup -fP --show "$IMG_FILE")

# 格式化分区
mkfs.vfat -F 32 "${LOOP_DEV}p1"
mkfs.ext4 "${LOOP_DEV}p2"

# 挂载并写入 EFI 分区
mkdir -p /mnt/efi /mnt/root
mount "${LOOP_DEV}p1" /mnt/efi
mkdir -p /mnt/efi/EFI/BOOT

# 生成 GRUB EFI (指向 ext4 分区)
grub-mkstandalone -O x86_64-efi -o /mnt/efi/EFI/BOOT/BOOTX64.EFI \
    "boot/grub/grub.cfg=/dev/stdin" <<EOF
set root=(hd0,gpt2)
set prefix=($root)/boot/grub
linux /boot/vmlinuz root=/dev/sda2 quiet
initrd /boot/initrd.img
boot
EOF

# 挂载并写入 RootFS 分区
mount "${LOOP_DEV}p2" /mnt/root
cp -a "$ROOTFS_DIR"/* /mnt/root/

# 清理
umount /mnt/efi /mnt/root
losetup -d "$LOOP_DEV"

echo "构建完成: $IMG_FILE"