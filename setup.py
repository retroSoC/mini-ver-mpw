#!/bin/python
import os

ROOT_PATH = os.getcwd()
MPW_PATH = f'{ROOT_PATH}/rtl/mini/mpw'

os.chdir(MPW_PATH)
os.system('rm -rf .build')
os.system('mkdir .build')

# if os.path.exists('Hazard3-main'):
    # print('file exist')
# else: os.system('git clone --recursive https://github.com/Wren6991/Hazard3.git Hazard3-main')

# os.system('mkdir -p core/username2/Hazard3')
# os.system('cp -rf Hazard3-main/hdl core/username2/Hazard3/')
