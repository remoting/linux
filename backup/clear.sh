#!/usr/bin/env bash

find /home/backup/ -name "*backup*" -type f -mtime +6 -exec rm -f {} \;