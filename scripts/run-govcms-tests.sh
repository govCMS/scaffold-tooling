#!/usr/bin/env bash
IFS=$'\n\t'

#skip|warn|fail
case ${1} in
    skip)
        echo "Skipping based on configuration"
        exit 0
        ;;
    warn)
        ;;
    *)
        set -euo pipefail
        ;;
esac

# If you modify anything above, please update all scripts in the same directory.

echo "$0 -- Is this: $1"
