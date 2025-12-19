#!/bin/bash

# =================================================================
# 脚本名称: auto_install_debian.sh
# 功能: 在第二块硬盘上自动安装 Debian 13 (Trixie) 并配置可移动引导
# 目标盘: /dev/sdb (请务必确认，以免误删数据)
# =================================================================
apt install -y parted gdisk dosfstools e2fsprogs debootstrap
set -e  # 出错立即停止

# 1. 基础参数定义
TARGET_DEV="/dev/sdb"
HOSTNAME="debian"
MIRROR="http://mirrors.aliyun.com/debian/"
MOUNT_DIR="/mnt"

echo "开始全自动安装流程..."
# 1. 尝试卸载并清理签名 (最核心的清理)
umount -l /mnt/boot/efi 2>/dev/null || true
umount -l /mnt 2>/dev/null || true

# 彻底擦除所有已知的文件系统、RAID、LVM 签名
wipefs -a "$TARGET_DEV" || true

# 关键：执行一次快速的物理抹除 (只需 1MB)，确分区表彻底消失
dd if=/dev/zero of="$TARGET_DEV" bs=1M count=1 conv=fdatasync

# 通知内核分区表已变
partprobe "$TARGET_DEV" || true
# 2. 磁盘分区 (使用 MBR)
echo "正在创建 MBR 分区..."
# 创建单分区作为根目录，设为启动分区 (bootable)
parted -s "$TARGET_DEV" mklabel msdos
parted -s "$TARGET_DEV" mkpart primary ext4 1MiB 100%
parted -s "$TARGET_DEV" set 1 boot on
# 强制刷新内核分区表
partprobe "$TARGET_DEV"
sleep 2

# 格式化分区
echo "正在格式化分区..."
mkfs.ext4 -F "${TARGET_DEV}1"

# 挂载并部署 Rootfs
echo "正在挂载分区并执行 debootstrap..."
mount "${TARGET_DEV}1" "$MOUNT_DIR"

# 安装基础系统及核心包 (内核、GRUB、基础工具)
debootstrap --arch=amd64 --include=linux-image-amd64,grub-pc,locales,isc-dhcp-client,vim,openssh-server trixie "$MOUNT_DIR" "$MIRROR"

# 4. 准备 Chroot 环境
echo "挂载虚拟文件系统..."
for i in /dev /dev/pts /proc /sys /run; do
    mount --bind "$i" "$MOUNT_DIR$i"
done

# 获取 UUID
UUID_ROOT=$(blkid -s UUID -o value "${TARGET_DEV}1")

# 5. 在新系统中进行配置 (Chroot 内部命令)
echo "进入 Chroot 进行配置..."
chroot "$MOUNT_DIR" /bin/bash <<EOF
set -e

# 拉黑 piix4 模块，消除第一行 SMBus 报错
cat >> /etc/modprobe.d/blacklist-vbox.conf <<MODPRO
blacklist evbug
blacklist uvcvideo
blacklist joydev
blacklist i2c_piix4
MODPRO


# 生成语言环境 (解决乱码的核心)
sed -i '/en_US.UTF-8 UTF-8/s/^# //g' /etc/locale.gen
sed -i '/zh_CN.UTF-8 UTF-8/s/^# //g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/default/locale

# 设置时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 禁用多余 TTY
systemctl mask getty@tty2.service getty@tty3.service getty@tty4.service getty@tty5.service getty@tty6.service
systemctl mask getty-static.service

# 极致精简 GRUB 参数
# pciehp.disable=1 解决你看到的几十个重复进程
# net.ifnames=0 强制网卡名为 eth0 (方便后面写死配置)
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet pciehp.disable=1 net.ifnames=0"/' /etc/default/grub

# 设置主机名
echo "$HOSTNAME" > /etc/hostname

cat > /etc/network/interfaces <<NETWORK
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
NETWORK


# 设置 root 密码 (默认为 123456，建议重启后修改)
echo "root:123456" | chpasswd

# 生成 fstab
cat > /etc/fstab <<FSTAB
UUID=$UUID_ROOT  /      ext4  errors=remount-ro  0  1
FSTAB

# 配置软件源
cat > /etc/apt/sources.list <<SOURCES
deb $MIRROR trixie main contrib non-free non-free-firmware
deb http://mirrors.aliyun.com/debian-security trixie-security main
SOURCES

# 允许 Root 登录 (按需开启)
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 确保服务开机自启
systemctl enable ssh.service
systemctl enable networking.service

# 安装 GRUB 到标准位置 (关键点：--removable 不依赖主板注册)
# 这样即使移除第一块硬盘，第二块硬盘在 /EFI/BOOT/ 下也有引导文件
update-initramfs -u
grub-install --target=i386-pc "$TARGET_DEV"
update-grub

EOF

# 6. 收尾工作
echo "安装完成，正在卸载..."
umount -R "$MOUNT_DIR"

echo "--------------------------------------------------------"
echo "恭喜！系统已成功安装到 $TARGET_DEV。"
echo "现在你可以关闭虚拟机，移除第一个硬盘，然后直接启动新硬盘。"
echo "默认密码为: 123456"
echo "--------------------------------------------------------"