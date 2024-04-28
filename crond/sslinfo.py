#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess 

dir=os.path.dirname(os.path.abspath(__file__))
os.chdir(dir)

# 执行 shell
def osExec(cmd):
    env = os.environ.copy()
    return subprocess.run(cmd,env=env,shell=True,stdout = subprocess.PIPE,stderr = subprocess.PIPE)
# 如果目录不存在，则创建,存在就清空
def mkdirs(directory):
    if not (os.path.exists(directory) and os.path.isdir(directory)):
        os.makedirs(directory)

def writeFile(name,content):
    f = open(name, 'w',encoding='UTF-8')
    f.write(content)
    f.close()

def delFile(name):
    if os.path.exists(name):
        os.remove(name)

def readFile(name):
    content=""
    with open(name, 'r', encoding='UTF-8') as file:
        content = file.read()
    return content

if __name__ == "__main__":
    print(os.getcwd())