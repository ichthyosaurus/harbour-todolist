#!/bin/bash
#
# This file is part of harbour-todolist.
# Copyright (C) 2020  Mirian Margiani
#
# harbour-todolist is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# harbour-todolist is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with harbour-todolist.  If not, see <http://www.gnu.org/licenses/>.
#

echo "rendering app icon..."

postfix=""
root="../icons"
appicons=(harbour-todolist)
for i in 86 108 128 172; do
    mkdir -p "$root/${i}x$i"

    for a in "${appicons[@]}"; do
        if [[ ! "$a.svg" -nt "$root/${i}x$i/$a$postfix.png" ]]; then
            echo "nothing to do for $a at ${i}x$i"
            continue
        fi

        inkscape -z -e "$root/${i}x$i/$a$postfix.png" -w "$i" -h "$i" "$a.svg"
    done
done


echo "rendering status icons..."

root="../qml/images"
files=(icon-todo@112 icon-ignored@112 icon-done@112 harbour-todolist@256
       icon-todo-small@24 icon-ignored-small@24 icon-done-small@24)
mkdir -p "$root"

for img in "${files[@]}"; do
    if [[ ! "${img%@*}.svg" -nt "$root/${img%@*}.png" ]]; then
        echo "nothing to do for '${img%@*}.svg'"
        continue
    fi

    inkscape -z -e "$root/${img%@*}.png" -w "${img#*@}" -h "${img#*@}" "${img%@*}.svg"
done
