#!/bin/bash
# Show the pause screen

../../../bin/jt1943_msg.py

function check_hex_file {
    if [ ! -e $1 ]; then
        if [ ! -e ../../mist/$1 ]; then
            echo Missing HEX files for PAUSE screen. Attempting to generate them:
            pushd
            cd ../../../bin
            python avatar.py
            popd
        fi
        echo INFO: Created symbolic link to $1
        ln -s ../../mist/$1
    fi
}

check_hex_file avatar.hex
check_hex_file avatar_xy.hex
check_hex_file avatar_pal.hex
check_hex_file avatar_obj.hex

if ! go.sh -frame 12 $*  -video -mist -d DIP_TEST -nosnd -d NOMAIN \
    -d AVATAR_DATA -d AVATAR_ROM \
    -d DIP_PAUSE -d NOSCR -d AVATARS -d SCANDOUBLER_DISABLE=1; then
    exit 1
fi
