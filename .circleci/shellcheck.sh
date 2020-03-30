#!/usr/bin/env bash

set -e

targets=()
while IFS=  read -r -d $'\0'; do
    targets+=("$REPLY")
done < <(
  find \
    scripts \
    .circleci/phpcs.sh \
    .circleci/shellcheck.sh \
    ! -name "README.*" \
    -type f \
    -print0
  )

for file in "${targets[@]}"; do
  [ -f "${file}" ] && LC_ALL=C.UTF-8 shellcheck "${file}"
done;
