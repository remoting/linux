#!/usr/bin/env bash
cd `dirname $0`

find /data/backup/ -name "*backup*" -type f -mtime +6 -exec rm -f {} \;