#!/bin/python
import os

ROOT_PATH = os.getcwd()
MPW_PATH = f'{ROOT_PATH}/rtl/mini/mpw'

os.chdir(MPW_PATH)
os.system('rm -rf .build')
os.system('mkdir .build')


os.system('git clone --recursive https://github.com/Wren6991/Hazard3.git core/username1/')