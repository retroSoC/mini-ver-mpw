#!/bin/python

import os
import re
import sys
import fnmatch
from pathlib import Path
import common


ROOT_PATH = os.getcwd()
MPW_PATH = f'{ROOT_PATH}/rtl/mini/mpw'

if len(sys.argv) < 2:
    print('example: python3 core.py SIMU')
    sys.exit(1)

simu = sys.argv[1]
print(f'simu: {simu}')


lines = ''
# remove parallel case statement
with open(f'{ROOT_PATH}/rtl/mini/core/picorv32.v', 'r', encoding='utf-8') as fp:
    for v in fp:
        if '// synopsys parallel_case' in v:
            lines += v.replace('// synopsys parallel_case', '')
        elif '// synopsys full_case parallel_case' in v:
            lines += v.replace('// synopsys full_case parallel_case', '')
        else:
            lines += v

with open(f'{ROOT_PATH}/rtl/mini/core/picorv32_ver.v', 'w', encoding='utf-8') as fp:
    fp.writelines(lines)

os.chdir(MPW_PATH)
os.system('rm -rf ./.build/core')
os.system('cp -rf ./core ./.build/')
os.chdir('./.build/core')
current_dir = Path.cwd()
# for path in current_dir.iterdir():
#     if path.is_dir():
#         common.rename_modules_with_folder_suffix(path.name)

with open('core.fl', 'w', encoding='utf-8') as fw:
    if simu == 'VCS':
        fw.write(f'{ROOT_PATH}/rtl/mini/core/picorv32.v\n')
    elif simu == 'VERILATOR':
        fw.write(f'{ROOT_PATH}/rtl/mini/core/picorv32_ver.v\n')
    for path in current_dir.iterdir():
        if path.is_dir() and path.name != 'username2':
            common.rename_modules_with_folder_suffix(path.name)
            with open(f'{path.name}/usercore.fl', 'r', encoding='utf-8') as fr:
                for v in fr:
                    if 'user_core_design.sv' in v:
                        v = f'./user_core_design_{path.name}.sv\n'
                        os.system(f'mv {current_dir}/{path.name}/user_core_design.sv {current_dir}/{path.name}/user_core_design_{path.name}.sv')
                    # print(v)
                    if 'incdir' in v:
                        res = v.split('+')
                        fw.write(f'+incdir+{current_dir}/{path.name}/{res[2]}')
                    else:
                        fw.write(f'{current_dir}/{path.name}/{v}')