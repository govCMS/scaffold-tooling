#!/usr/bin/env bash
IFS=$'\n\t'

# Rudimentary help.
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 [skip|warning|strict]"
	exit 1
fi

if [ "$1" = "skip" ] ; then
    echo "Skipping $0"
    exit 0
fi

if [ "$1" != "warning" ] ; then
    # @see http://redsymbol.net/articles/unofficial-bash-strict-mode/
    set -euo pipefail
    echo "Strictly $0"
fi

echo "$0 -- Is this $1"
