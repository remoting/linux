#!/bin/bash
cd `dirname $0`
# 设置要检查的域名和端口
DOMAIN="www.baidu.com"  #域名
PORT=443              #端口

# 获取SSL证书信息
CERT_INFO=$(openssl s_client -connect ${DOMAIN}:${PORT} -showcerts </dev/null 2> /dev/null | openssl x509 -noout -dates)
ISSUER=$(openssl s_client -connect ${DOMAIN}:${PORT} -showcerts </dev/null 2> /dev/null | openssl x509 -noout -issuer)
DOMAIN=$(openssl s_client -connect ${DOMAIN}:${PORT} -showcerts </dev/null 2> /dev/null | openssl x509 -noout -ext subjectAltName | grep DNS)
# 提取证书过期日期信息
START_DATE=$(echo "${CERT_INFO}" | grep "notBefore" | cut -d'=' -f 2)
END_DATE=$(echo "${CERT_INFO}" | grep "notAfter" | cut -d'=' -f 2)

# 将日期转换为Unix时间戳
START_TIMESTAMP=$(date -d "${START_DATE}" +%s)
END_TIMESTAMP=$(date -d "${END_DATE}" +%s)
CURRENT_TIMESTAMP=$(date +%s)
START_DATETIME=$(date -d "${START_DATE}" +'%Y-%m-%d %H:%M:%S')
EDN_DATETIME=$(date -d "${END_DATE}" +'%Y-%m-%d %H:%M:%S')

# 计算剩余天数
DAYS_REMAINING=$(( (${END_TIMESTAMP} - ${CURRENT_TIMESTAMP}) / 86400 ))

# 输出结果
echo "SSL证书信息:"
echo " - 发行: ${ISSUER}"
echo " - 域名: ${DOMAIN}"
echo " - 证书开始日期: ${START_DATE} ，标准格式展示: ${START_DATETIME}"
echo " - 证书过期日期: ${END_DATE} ，标准格式展示: ${EDN_DATETIME}"
echo " - 剩余天数: ${DAYS_REMAINING} 天"

# 检查是否过期
if [ ${CURRENT_TIMESTAMP} -gt ${END_TIMESTAMP} ]; then
  echo "证书已过期！"
else
  echo "证书在有效期内。"
fi

# 检查是否过期
if [ ${DAYS_REMAINING} -le 3 ]; then
  echo "已小于3天"
else
  echo "剩余天数: ${DAYS_REMAINING} 天"
fi