#!/usr/bin/env bash

set -e

targets=()
while IFS=  read -r -d $'\0'; do
    targets+=("$REPLY")
done < <(
  find \
    scripts \
    tests/bats \
    .ci/bats.sh \
    .ci/phpcs.sh \
    .ci/shellcheck.sh \
    -type f \
    \( ! -name "README.*" -and ! -name "_bats-mock.bash" -and \
       ! -name "govcms-yaml_lint" -and ! -name "govcms-module_verify" -and \
       ! -name "govcms-prepare-xml" -and ! -name "*.yml" -and \
       ! -name "*.php" -and ! -name "*.json" -and ! -name "*.theme" -and \
       ! -name "*.inc" -and ! -name "*.neon" \) \
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
