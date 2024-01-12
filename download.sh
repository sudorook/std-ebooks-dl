#!/bin/bash

# SPDX-FileCopyrightText: 2022 - 2024 sudorook <daemon@nullcodon.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.

set -euo pipefail

PREFIX="https://standardebooks.org/ebooks"

function download_epubs {
  local line
  local file
  while read -r line; do
    file="${line//\//_}.epub"
    # file="${line//\//_}_advanced.epub"
    if ! [ -f "${file}" ]; then
      echo -n "${file@Q}... "
      curl -s -O "${PREFIX}/${line}/downloads/${file}"
      echo "done."
      sleep $((RANDOM % 10 + 10))
    else
      echo "${file@Q} already exists. Skipping."
    fi
  done
}

function get_page_count {
  curl -s "https://standardebooks.org/ebooks" |
    sed -n "s,\s\+<li><a href=\"/ebooks?page=[0-9]\+\">\([0-9]\+\)</a></li>,\1,p" |
    tail -n 1
}

PAGES="$(get_page_count)"
if [ -z "${PAGES}" ]; then
  echo "Parsing page count failed. Exiting."
  exit 3
fi

echo "Downloading ${PAGES} pages."
for PAGE in $(seq 1 "${PAGES}"); do
  echo "${PREFIX}?page=${PAGE}"
  curl -s "${PREFIX}?page=${PAGE}" |
    sed -n "s/.*about=\"\/ebooks\/\(.*\)\">/\1/p" |
    download_epubs
  echo
done
