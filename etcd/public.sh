#!/bin/bash

rsync -r --delete --progress --exclude='.git' ./3.3.9/ root@172.16.211.134:/root/3.3.9/
