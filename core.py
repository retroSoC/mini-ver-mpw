#!/bin/python

import os
import re
import sys
import fnmatch
from pathlib import Path
import common

ban_list = ['hazard3_config', 'hazard3_config_inst', 'hazard3_rvfi_monitor', 'hazard3_rvfi_standalone_defs', 'hazard3_width_const']

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

with open('core.fl', 'w', encoding='utf-8') as fw:
    if simu == 'VCS':
        fw.write(f'{ROOT_PATH}/rtl/mini/core/picorv32.v\n')
    elif simu == 'VERILATOR':
        fw.write(f'{ROOT_PATH}/rtl/mini/core/picorv32_ver.v\n')

    sorted_paths = sorted(current_dir.iterdir(), key=lambda p: p.name)
    for path in sorted_paths:
        print(path)
        if path.is_dir():
            # rename all module
            common.rename_contents_with_folder_suffix(path.name)
            with open(f'{path.name}/usercore.fl', 'r', encoding='utf-8') as fr:
                for v in fr:
                    # print(v)
                    if 'incdir' in v:
                        res = v.split('+')
                        fw.write(f'+incdir+{current_dir}/{path.name}/{res[-1]}')
                    else:
                        old_filename = v.split('/')[-1].rstrip('\n')
                        new_filename = f'{old_filename.split(".")[0]}_{path.name}.{old_filename.split(".")[1]}'

                        old_filepath = f'{os.path.dirname(v)}/{old_filename}'
                        new_filepath = f'{os.path.dirname(v)}/{new_filename}'
                        # mv
                        os.system(f'mv {current_dir}/{path.name}/{old_filepath} {current_dir}/{path.name}/{new_filepath}')
                        # print(f'file: {current_dir}/{path.name}/{new_filepath}')
                        is_ban = False
                        for v in ban_list:
                            if v in new_filename:
                                is_ban = True
                                break

                        if is_ban is False:
                            fw.write(f'{current_dir}/{path.name}/{new_filepath}\n')
            fw.write('\n')