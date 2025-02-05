#!/bin/bash

# Please note that ET: Legacy is not compatible with PunkBuster enabled servers. ET: Legacy clients also cannot connect to servers running the ETPro mod.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
"${DIR}/etlded.x86_64" \
    +set dedicated 2 \
    +set vm_game 0 \
    +set net_port 27960 \
    +set sv_maxclients 20 \
    +set fs_game legacy \
    +set sv_punkbuster 0 \
    +set fs_basepath "${DIR}" \
    +set fs_homepath "${DIR}" \
    +exec server.cfg
