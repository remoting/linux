#!/bin/sh

nohup consul agent -config-dir=/usr/local/etc/consul/ >> /data/tmp/consul/logs/logs.log 2>&1 &