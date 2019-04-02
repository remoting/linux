#!/bin/bash
cd `dirname $0`

nohup ./consul.sh $1 $2 $3 &

exec caddy --conf Caddyfile