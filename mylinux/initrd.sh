#!/bin/bash
# 设置基础路径
SOURCE_DIR=~/mini_initrd
OUTPUT_IMG=~/initrd.img

rm -rf "$SOURCE_DIR"
rm -f "$OUTPUT_IMG"

mkdir -p $SOURCE_DIR/{bin,sbin,etc,proc,sys,dev,mnt}
cd $SOURCE_DIR

# 将静态编译的 busybox 拷贝进来并安装所有命令
cp /usr/bin/busybox bin/busybox
chmod +x bin/busybox
# 让 busybox 自动创建 ls, cp, sh 等符号链接
cd bin && ./busybox --install . && cd ..
cd $SOURCE_DIR

cat <<EOF > "$SOURCE_DIR/init"
#!/bin/sh

# 1. 挂载必要的内核虚拟文件系统
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# 2. 欢迎信息
echo "========================================"
echo "   Welcome to my RAM-based Linux OS!   "
echo "========================================"

# 3. 自动探测并挂载 U 盘的分区到 /mnt (假设 U 盘是 sda1)
# 你可以在这里加入之前讨论的 apps 挂载逻辑
echo "Scanning for USB partitions..."
sleep 2
mount /dev/sda1 /mnt 2>/dev/null && echo "USB Drive mounted at /mnt"

# 4. 启动一个交互式的 Shell（这就是你的操作系统界面）
echo "Starting system shell..."
exec /bin/sh
EOF

chmod +x init
find . | cpio -o -H newc | gzip > $OUTPUT_IMG