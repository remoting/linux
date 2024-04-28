#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import file

# 确保当前目录
dir=os.path.dirname(os.path.abspath(__file__))
os.chdir(dir)

if __name__ == "__main__":
    print(os.getcwd())
    print(sys.path)
    print(file.readFile("./file.py"))