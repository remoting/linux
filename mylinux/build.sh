#!/bin/bash
# 设置基础路径
export WORK_DIR=~/iso_build
export OUTPUT_ISO=~/mylinux.iso

# 1. 环境清理与目录创建
rm -rf "$WORK_DIR"
rm -f "$OUTPUT_ISO"

./rootfs.sh
