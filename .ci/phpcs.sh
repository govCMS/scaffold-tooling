#!/usr/bin/env bash

set -e

targets=()
while IFS=  read -r -d $'\0'; do
    targets+=("$REPLY")
done < <(
  find \
    drupal \
    -type f \
    -print0
  )

composer global config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
composer global require drupal/coder
composer global require dealerdirect/phpcodesniffer-composer-installer

for file in "${targets[@]}"; do
  [ -f "${file}" ] && /home/.composer/vendor/bin/phpcs --standard=Drupal,DrupalPractice -s --colors "${file}"
done;
