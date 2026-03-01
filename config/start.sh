#!/bin/bash

# Please note that ET: Legacy is not compatible with PunkBuster enabled servers. ET: Legacy clients also cannot connect to servers running the ETPro mod.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Ensure log directory exists under fs_homepath
FS_HOMEPATH="${FS_HOMEPATH:-${DIR}}"
mkdir -p "${FS_HOMEPATH}/legacy/log"

# Apply environment variable substitution to config template if it exists
if [ -f "${DIR}/legacy/server.cfg.template" ]; then
    envsubst < "${DIR}/legacy/server.cfg.template" > "${DIR}/legacy/server.cfg"
fi

# Find the etlded binary for the current architecture
ETLDED=$(find "${DIR}" -maxdepth 1 -name 'etlded.*' -type f | head -1)
if [ -z "${ETLDED}" ]; then
    echo "ERROR: etlded binary not found in ${DIR}" >&2
    exit 1
fi

exec "${ETLDED}" "$@"
