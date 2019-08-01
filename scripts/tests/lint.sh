#!/usr/bin/env bash
IFS=$'\n\t'

STRICTNESS=${1}
TYPE="$(basename $0)"
case ${STRICTNESS} in
    skip)
        echo "Skipping "${TYPE}" based on configuration." && exit 0 ;;
    warn)
        ;;
    fail | *)
        STRICTNESS="fail" && set -euo pipefail ;;
esac
echo "Running '"${TYPE}"' and will "${STRICTNESS}" on failures."

#
# If you modify anything above this line, please update all scripts in the same directory.
#