# Automatically re-run script under sudo if not root
if [ $(id -u) -ne 0 ]; then
    echo "Re-running script under sudo..."
    sudo "$0" "$@"
    exit
fi

# Checking device for fusing
if [ -z $1 ]; then
    echo "Usage: ./fushing /dev/sdx"
    exit 0
fi

case $1 in
/dev/sd[a-z] | /dev/loop[0-9])
    if [ ! -e $1 ]; then
        echo "Error: $1 does not exist."
        exit 1
    fi
    DEV_NAME=`basename $1`
    BLOCK_CNT=`cat /sys/block/${DEV_NAME}/size` ;;&
/dev/sd[a-z])
    REMOVABLE=`cat /sys/block/${DEV_NAME}/removable` ;;
/dev/loop[0-9])
    REMOVABLE=1 ;;
*)
    echo "Error: Unsupported SD reader"
    exit 0
esac

if [ ${REMOVABLE} -le 0 ]; then
    echo "Error: $1 is non-removable device. Stop."
    exit 1
fi

if [ -z ${BLOCK_CNT} -o ${BLOCK_CNT} -le 0 ]; then
    echo "Error: $1 is inaccessible. Stop fusing now!"
    exit 1
fi

let DEV_SIZE=${BLOCK_CNT}/2
if [ ${DEV_SIZE} -gt 64000000 ]; then
    echo "Error: $1 size (${DEV_SIZE} KB) is too large"
    exit 1
fi

if [ ${DEV_SIZE} -le 3800000 ]; then
    echo "Error: $1 size (${DEV_SIZE} KB) is too small"
    echo "       At least 4GB SDHC card is required, please try another card."
    exit 1
fi

# Confirm fushing
echo "Are you sure to update boot loader! Continue ? [y/n]"
read ans
if ! [ $ans == 'y' ]
then
    exit
fi

echo "[Unmounting all existing partitions on the device]"

umount $1*

# Generate bootloader
echo "[Generate bootloader...]"
./bootgen bootloader.bin u-boot.bin

DRIVE=$1
SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`
echo [Disk size = $SIZE bytes]

# Write MBR
echo "[Write MBR...]"
dd if=bootloader.bin of=${DRIVE} bs=512 seek=1 &> /dev/null

echo "[Done]"
