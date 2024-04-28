# -*- coding: utf-8 -*-
import os
import subprocess

# 执行 shell
def osExec(cmd):
    env = os.environ.copy()
    return subprocess.run(cmd,env=env,shell=True,stdout = subprocess.PIPE,stderr = subprocess.PIPE)

# 如果目录不存在
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