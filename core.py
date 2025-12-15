import os
import re
import fnmatch
from pathlib import Path
import common

ROOT_PATH = os.getcwd()
MPW_PATH = f'{ROOT_PATH}/rtl/mini/mpw'


os.chdir(MPW_PATH)
os.system('rm -rf ./.build/core')
os.system('cp -rf ./core ./.build/')

os.chdir('./.build/core')
current_dir = Path.cwd()
for path in current_dir.iterdir():
    if path.is_dir():
        common.rename_modules_with_folder_suffix(path.name)

with open('core.fl', 'w', encoding='utf-8') as fw:
    fw.write(f'{ROOT_PATH}/rtl/mini/core/picorv32.v\n')
    for path in current_dir.iterdir():
        if path.is_dir():
            with open(f'{path.name}/usercore.fl', 'r', encoding='utf-8') as fr:
                for v in fr:
                    if 'user_core_design.sv' in v:
                        v = f'./user_core_design_{path.name}.sv\n'
                        os.system(f'mv {current_dir}/{path.name}/user_core_design.sv {current_dir}/{path.name}/user_core_design_{path.name}.sv')
                    # print(v)
                    fw.write(f'{current_dir}/{path.name}/{v}')

                fw.write(f'+incdir+{current_dir}/{path.name}/kianV')
