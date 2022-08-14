#! /bin/bash
set -euo pipefail

PREFIX="https://standardebooks.org/ebooks"

function download_epubs {
  local line
  while read -r line; do
    echo "${line}"
    wget --quiet -nc "${PREFIX}/${line}/downloads/${line//\//_}.epub"
    wget --quiet -nc "${PREFIX}/${line}/downloads/${line//\//_}_advanced.epub"
    sleep $((RANDOM % 10 + 10))
  done
}

for PAGE in $(seq 1 59); do
  echo "${PREFIX}?page=${PAGE}"
  curl "${PREFIX}?page=${PAGE}" | \
    grep "about=\"/ebooks" | \
    sed -n "s/.*about=\"\/ebooks\/\(.*\)\">/\1/p" | \
    download_epubs
  echo
done
