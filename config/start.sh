#!/bin/bash

# Please note that ET: Legacy is not compatible with PunkBuster enabled servers. ET: Legacy clients also cannot connect to servers running the ETPro mod.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Ensure log directory exists under fs_homepath
FS_HOMEPATH="${FS_HOMEPATH:-${DIR}}"
mkdir -p "${FS_HOMEPATH}/legacy/log"

exec "${DIR}/etlded.x86_64" "$@"
