#!/bin/bash

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
files=(icon-todo@112 icon-ignored@112 icon-done@112 harbour-todolist@256)
mkdir -p "$root"

for img in "${files[@]}"; do
    if [[ ! "${img%@*}.svg" -nt "$root/${img%@*}.png" ]]; then
        echo "nothing to do for '${img%@*}.svg'"
        continue
    fi

    inkscape -z -e "$root/${img%@*}.png" -w "${img#*@}" -h "${img#*@}" "${img%@*}.svg"
done
