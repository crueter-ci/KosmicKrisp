#!/bin/sh -e

_repo=V380-Ori/Ryujinx.MoltenVK
_artifact=MoltenVK-macos.tar
_tag=v1.4.1
_dir=$PWD/install

_url=https://github.com/$_repo/releases/download/$_tag-ryujinx/$_artifact

[ -f $_artifact ] || curl -L "$_url" -o "$_artifact"
[ -d "$_dir"/MoltenVK ] || tar xf "$_artifact" -C "$_dir"