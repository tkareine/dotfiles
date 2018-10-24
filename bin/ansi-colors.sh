#!/usr/bin/env bash

printf 'ANSI 16:\n\n'

for bold in 0 1; do
    for color in {30..37}; do
        printf '\e[%s;%sm  %3s  \e[0m' "$bold" "$color" "$color"
    done

    echo
done

printf '\nANSI 256:\n\n'

for color in {0..255}; do
    printf '\e[1;38;5;%sm  %3s  \e[0m' "$color" "$color"

    (($(((color + 1) % 6)) == 4)) && echo
done
