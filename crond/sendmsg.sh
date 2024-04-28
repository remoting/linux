#!/bin/bash
cd `dirname $0`

message=$1
 
curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=3a794cad-038e-4192-9cb3-58d73e8b32a4' -H 'Content-Type: application/json' -d '{"msgtype": "text","text":{"content": "'"$message"'"}}'