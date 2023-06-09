#!/bin/bash

OUT="$1"
shift

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
name="${OUT##*.}" # "./.xyz" --> "xyz"

mkdir --parents "$OUT"

readarray -d '' scripts < <( find "$here/$name" -path "*.sh" -type f -print0 )
for script in "${scripts[@]}" ; do

  run="$OUT/$(basename "$script" ".sh")"
  mkdir --parents "$run"
  "$script" "$run" "$@"

done
