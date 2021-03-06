#!/bin/bash

MIST=-mist
VIDEO=0

for k in $*; do
    if [ "$k" = -mister ]; then
        echo "MiSTer setup chosen."
        MIST=$k
    fi
    if [ "$k" = -video ]; then
        VIDEO=1
    fi
done

export GAME_ROM_PATH=../../../rom/sectionz.rom
export MEM_CHECK_TIME=106_000_000
export CONVERT_OPTIONS="-resize 300%x300%"
GAME_ROM_LEN=$(stat -c%s $GAME_ROM_PATH)
export YM2203=1

# Generic simulation script from JTFRAME
echo "Game ROM length: " $GAME_ROM_LEN
$JTFRAME/bin/sim.sh $MIST -d GAME_ROM_LEN=$GAME_ROM_LEN  \
    -sysname sectionz -modules ../../../modules \
    -videow 256 -videoh 240 \
    -d BUTTONS=2 \
    -d COLORW=4  \
    -d JTFRAME_SIM_LOAD_EXTRA=24 \
    -d SCANDOUBLER_DISABLE=1 $*
