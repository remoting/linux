cat <<EOF > "$SOURCE_DIR/init"
#!/bin/sh

# 1. 挂载必要的内核虚拟文件系统
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# 2. 欢迎信息
echo "========================================"
echo "   Entering initrd stage...             "
echo "========================================"

# 3. 等待内核识别设备（非常重要，U 盘识别较慢）
echo "Waiting for USB device to be ready..."
sleep 5

# 4. 尝试挂载 U 盘第一个分区到临时目录 /newroot
mkdir -p /newroot
# 这里推荐使用 UUID 或标签，但如果你确定是 /dev/sda1：
if mount /dev/sda1 /newroot; then
    echo "USB Partition mounted successfully."
    
    # 5. 检查新根目录是否包含 init 程序
    if [ -x /newroot/sbin/init ] || [ -x /newroot/bin/sh ]; then
        echo "Switching to real root filesystem..."
        
        # 6. 清理并切换根目录
        # 参数说明: 新根目录路径, init程序路径 (通常是 /sbin/init)
        exec switch_root /newroot /sbin/init
    else
        echo "Error: No init found on /dev/sda1!"
    fi
else
    echo "Error: Could not mount /dev/sda1."
fi

# 如果切换失败，回退到 initrd 的救援 Shell
echo "Falling back to rescue shell..."
exec /bin/sh
EOF



# 在 initrd 的 init 脚本里
TARGET_UUID="你在脚本里获取到的那个UUID"
echo "Waiting for partition $TARGET_UUID..."
sleep 5 # 给 U 盘驱动加载留时间

# 自动扫描并挂载
found_dev=$(blkid -U "$TARGET_UUID")
if [ -n "$found_dev" ]; then
    mount "$found_dev" /newroot
    exec switch_root /newroot /sbin/init
else
    echo "Panic: Root partition not found!"
    exec /bin/sh
fi