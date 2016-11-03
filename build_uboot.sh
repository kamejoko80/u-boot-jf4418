#!/bin/bash

wget https://github.com/pdtechvn/toolschain/raw/master/arm-cortexa9-linux-gnueabihf-4.9.3.tar.xz
tar -xvf arm-cortexa9-linux-gnueabihf-4.9.3.tar.xz

echo [Build u-boot...]
ARCH_TYPE=arm
CROSS_COMPILE_TYPE=`pwd`/4.9.3/bin/arm-none-linux-gnueabihf-
sudo make ARCH=$ARCH_TYPE CROSS_COMPILE=$CROSS_COMPILE_TYPE distclean
sudo make ARCH=$ARCH_TYPE CROSS_COMPILE=$CROSS_COMPILE_TYPE s5p4418_jf4418_config
sudo make ARCH=$ARCH_TYPE CROSS_COMPILE=$CROSS_COMPILE_TYPE
