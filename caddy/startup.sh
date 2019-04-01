#!/bin/bash
cd `dirname $0`

nohup ./consul.sh $1 $2 &

exec caddy --conf Caddyfile