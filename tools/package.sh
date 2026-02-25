#!/bin/sh

_out="$PWD/out"
_lib="$_out/lib"
_icd="$_out/vulkan/icd.d"

mkdir -p "$_lib" "$_icd"

find install \( -type f -o -type l \) -name '*.dylib' -exec cp {} "$_lib" \;
find install -type f -name '*icd*json' -exec cp {} "$_icd" \;