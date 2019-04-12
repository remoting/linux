#!/bin/bash

rsync -r --delete --progress --exclude='.git' ./certs.sh root@10.11.46.204:/tmp/pki