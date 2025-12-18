apt install busybox-static
apt install binutils
apt install dosfstools
apt install mtools
apt install xorriso



mkdir -p "$WORK_DIR"/{boot/grub,EFI/BOOT}

# 2. 准备内核和 initrd 
cp ~/initrd.img "$SOURCE_DIR/"
cp /boot/vmlinuz-6.12.57+deb13-amd64 "$SOURCE_DIR/vmlinuz"

# 3. 创建 grub.cfg
# 增加 insmod 确保 GRUB 启动后能读到 ISO 里的内容
cat <<EOF > "$SOURCE_DIR/boot/grub/grub.cfg"
insmod part_gpt
insmod iso9660
insmod gzio

set timeout=5
set default=0

menuentry "My Custom Linux" {
    # 强制搜索卷标为 MYLINUX 的设备并设为根目录
    search --no-floppy --label MYLINUX --set=root
    linux /vmlinuz quiet
    initrd /initrd.img
}
EOF

# 4. 生成独立的 GRUB EFI 引导程序
# 注意：这里我们将当前目录切换到 SOURCE_DIR，以简化 grub-mkstandalone 的路径映射
cd "$SOURCE_DIR"
grub-mkstandalone -O x86_64-efi \
    -o "$SOURCE_DIR/EFI/BOOT/BOOTX64.EFI" \
    "boot/grub/grub.cfg=boot/grub/grub.cfg"

# 5. 创建 20MB 的 EFI 启动分区镜像 (FAT 格式)
dd if=/dev/zero of=efiboot.img bs=1M count=20
mkfs.vfat efiboot.img

# 6. 将生成的 EFI 文件放入镜像
# 使用 mmd 和 mcopy 直接操作，无需 root
mmd -i efiboot.img ::/EFI
mmd -i efiboot.img ::/EFI/BOOT
mcopy -i efiboot.img "$SOURCE_DIR/EFI/BOOT/BOOTX64.EFI" ::/EFI/BOOT/

# 7. 使用 xorriso 生成最终的 ISO
# 核心逻辑：
# -e 指定 efiboot.img 为 EFI 引导分区
# -append_partition 2 0xef 确保该镜像也被写入分区表，增加兼容性
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "MYLINUX" \
    -eltorito-alt-boot \
    -e efiboot.img \
    -no-emul-boot \
    -append_partition 2 0xef efiboot.img \
    -output "$OUTPUT_ISO" \
    .
