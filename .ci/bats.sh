#!/usr/bin/env bash

set -e

targets=()
while IFS=  read -r -d $'\0'; do
    targets+=("$REPLY")
done < <(find tests/bats -type f -name "*.bats"  -print0)

for file in "${targets[@]}"; do
  [ -f "${file}" ] && bats "${file}"
done;
