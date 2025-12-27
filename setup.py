#!/bin/python
import os

ROOT_PATH = os.getcwd()
MPW_PATH = f'{ROOT_PATH}/rtl/mini/mpw'

os.chdir(MPW_PATH)
os.system('rm -rf .build')
os.system('mkdir .build')

if os.path.exists('Hazard3-main'):
    print('Hazard3 repo exist')
else: os.system('git clone --recursive https://github.com/Wren6991/Hazard3.git Hazard3-main')


if os.path.exists('core/username3/Hazard3'):
    print('username3 repo exist')
else:
    os.system('mkdir -p core/username3/Hazard3')
    os.system('cp -rf Hazard3-main/hdl core/username3/Hazard3/')


if os.path.exists('serv-1.4.0.tar.gz'):
    print('serv file exist')
else:
    os.system('wget https://github.com/olofk/serv/archive/refs/tags/1.4.0.tar.gz -O serv-1.4.0.tar.gz')
    os.system('tar -xvf serv-1.4.0.tar.gz')



if os.path.exists('core/username4/serv'):
    print('username4 repo exist')
else:
    os.system('mkdir -p core/username4/serv')
    os.system('cp -rf serv-1.4.0/rtl core/username4/serv/')