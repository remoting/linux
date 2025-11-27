#!/bin/bash
# 批量查看运行中容器的磁盘大小（适配 containerd + overlayfs）

# 遍历所有运行中容器
for CONTAINER_ID in $(sudo crictl ps -q); do
    # 获取容器基本信息
    CONTAINER_NAME=$(sudo crictl inspect $CONTAINER_ID | jq -r '.status.metadata.name')
    POD_NAME=$(sudo crictl inspect $CONTAINER_ID | jq -r '.status.labels["io.kubernetes.pod.name"]')
    # --- 2. 添加跳过逻辑 ---
    if [[ "$CONTAINER_NAME" == "logtail" || "$CONTAINER_NAME" == "node-exporter" || "$CONTAINER_NAME" == "kube-flannel" ]]; then
        echo "--- 容器名 $CONTAINER_NAME (属于 $POD_NAME) 被跳过 ---"
        continue # 跳过当前循环，进入下一个 CONTAINER_ID
    fi

    NAMESPACE=$(sudo crictl inspect $CONTAINER_ID | jq -r '.status.labels["io.kubernetes.pod.namespace"]')

    # 获取快照路径并计算磁盘大小
    PID=$(sudo crictl inspect $CONTAINER_ID | jq -r '.info.pid')
    SNAPSHOT_PATH=$(cat /proc/$PID/mounts | grep upperdir | grep -o 'upperdir=[^,]*' | awk -F '=' '{print $2}')
    DISK_SIZE=$(sudo du -sh $SNAPSHOT_PATH 2>/dev/null | awk '{print $1}')

    # 输出汇总信息
    echo "========================================"
    echo "容器ID: $CONTAINER_ID"
    echo "容器名: $CONTAINER_NAME"
    echo "所属Pod: $POD_NAME (命名空间: $NAMESPACE)"
    echo "磁盘占用: $DISK_SIZE"
done