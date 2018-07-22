#!/bin/bash

rsync -r --delete --progress --exclude='.git' ./1.10/ root@172.16.211.131:/root/1.10/