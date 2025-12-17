#!/bin/python

import os
import re
import fnmatch
from pathlib import Path
import common

ROOT_PATH = os.getcwd()
MPW_PATH = f'{ROOT_PATH}/rtl/mini/mpw'

os.chdir(MPW_PATH)
os.system('rm -rf ./.build/ip')
os.system('cp -rf ./ip ./.build/')

os.chdir('./.build/ip')
current_dir = Path.cwd()
for path in current_dir.iterdir():
    if path.is_dir():
        common.rename_modules_with_folder_suffix(path.name)

with open('ip.fl', 'w', encoding='utf-8') as fw:
    for path in current_dir.iterdir():
        if path.is_dir():
            # print(path.name)
            with open(f'{path.name}/userip.fl', 'r', encoding='utf-8') as fr:
                for v in fr:
                    if 'user_ip_design.sv' in v:
                        v = f'./user_ip_design_{path.name}.sv'
                        os.system(f'mv {current_dir}/{path.name}/user_ip_design.sv {current_dir}/{path.name}/user_ip_design_{path.name}.sv')
                    # print(v)
                fw.write(f'{current_dir}/{path.name}/{v}\n')
