#!/usr/bin/env bash

set -e

bats ./tests/bats
bats ./tests/bats/settings
