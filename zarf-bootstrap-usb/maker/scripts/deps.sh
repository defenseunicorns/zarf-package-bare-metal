#!/bin/bash

DEPS="$1"

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir --parents "$DEPS"

readarray -d '' scripts < <( find "$here/deps" -path "*.sh" -type f -print0 )
for script in "${scripts[@]}" ; do
  DEP="$DEPS/$(basename "$script" ".sh")"
  mkdir --parents "$DEP"
  "$script" "$DEP"
done
