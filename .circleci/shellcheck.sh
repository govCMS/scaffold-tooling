#!/usr/bin/env bash

set -e

targets=()
while IFS=  read -r -d $'\0'; do
    targets+=("$REPLY")
done < <(
  find \
    scripts \
    tests/bats \
    .circleci/bats.sh \
    .circleci/phpcs.sh \
    .circleci/shellcheck.sh \
    -type f \
    \( ! -name "README.*" -and ! -name "_bats-mock.bash" \) \
    -print0
  )

for file in "${targets[@]}"; do
  if [ -f "${file}" ]; then
    echo "Checking file ${file}"
    if ! LC_ALL=C.UTF-8 shellcheck "${file}"; then
      exit 1
    fi
  fi
done;
