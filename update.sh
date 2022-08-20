#!/usr/bin/env -S nix shell nixpkgs#git -c bash

if [ "$#" -gt 1 ] || [[ "$1" == -* ]]; then
  echo "Regenerates packaging data for the JShelter package."
  echo "Usage: $0 [git release tag]"
  exit 1
fi

version="$1"

set -euo pipefail

workingdir=$PWD
tmpdir=$(mktemp -d)
cd $tmpdir

if [ -z "$version" ]; then
  git clone https://pagure.io/JShelter/webextension
  cd webextension
  version=$(git tag -l --sort=committerdate | tail -1)
fi

hash=$(nix-prefetch-url "https://pagure.io/JShelter/webextension/archive/${version}/webextension-${version}.zip" --unpack)

nsclRev=$(git submodule | tail -c +2 | head -c 40)
nsclHash=$(nix-prefetch-url "https://github.com/hackademix/nscl/archive/$nsclRev.zip" --unpack)

cd $workingdir
rm -rf $tmpdir

cat > pin.json << EOF
{
  "version": "$version",
  "hash": "$hash",
  "nsclRev": "$nsclRev",
  "nsclHash": "$nsclHash"
}
EOF