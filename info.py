#!/bin/python

import os
import sys
from pathlib import Path
import tomli


ROOT_PATH = os.getcwd()
MPW_PATH = f'{ROOT_PATH}/rtl/mini/mpw'
CORE_PATH = f'{MPW_PATH}/.build/core'
IP_PATH = f'{MPW_PATH}/.build/ip'


def add_design_info(path, design_type):
    info = []
    os.chdir(f'{path}')
    current_dir = Path.cwd()
    sorted_paths = sorted(current_dir.iterdir(), key=lambda p: p.name)
    for path in sorted_paths:
        if 'username7' in path.name:
            continue

        if path.is_dir():
            with open(f'{path}/config.toml', 'rb') as f:
                res = tomli.load(f)
            info.append(res)

    # print(f'info: {info}')

    tmp_content = ''
    is_find_first = True

    with open(f'{MPW_PATH}/.build/user_design_info.h', 'r', encoding='utf-8') as fp:
            tmp_content = fp.readlines()

    # print(f'tmp_content: {tmp_content}')
    for idx, val in enumerate(tmp_content):
        target = 'none'
        if design_type == 'CORE':
            target = 'PicoRV32'
        elif design_type == 'IP':
            target = 'archinfo'
        
        if target in val and is_find_first:
            is_find_first = False
            for vidx, vval in enumerate(info):
                tmp_content.insert(idx + vidx + 1, f'    {{"{vval["name"]}", "{vval["isa"]}", "{vval["maintainer"]}", "{vval["repo"]}"}},\n')


    with open(f'{MPW_PATH}/.build/user_design_info.h', 'w', encoding='utf-8') as fp:
        fp.writelines(tmp_content)
    print('')


if len(sys.argv) < 2:
    print('example: python3 info.py CORE')
    sys.exit(1)

design_type = sys.argv[1]
print(f'design_type: {design_type}')


if os.path.exists(f'{MPW_PATH}/.build/user_design_info.h'):
    print('user info file exist')
else:
    os.system(f'cp -rf {MPW_PATH}/user_design_info.h {MPW_PATH}/.build/user_design_info.h')


if design_type == 'CORE':
    add_design_info(CORE_PATH, design_type)

elif design_type == 'IP':
    add_design_info(IP_PATH, design_type)