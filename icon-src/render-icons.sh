#!/bin/bash
#
# This file is part of Opal and has been released into the public domain.
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2021-2023 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/main/snippets/opal-render-icons.md
# for documentation.
#
# @@@ keep this line: based on template v1.0.0
#
c__FOR_RENDER_LIB__="1.0.0"

# Run this script from the same directory where your icon sources are located,
# e.g. <app>/icon-src.
source ../libs/opal-render-icons.sh
cFORCE=false

for i in raw/*.svg; do
    if [[ "$i" -nt "${i#raw/}" ]]; then
        scour "$i" > "${i#raw/}"
    fi
done

cMY_APP=harbour-todolist

cNAME="app icons"
cITEMS=("$cMY_APP")
cRESOLUTIONS=(86 108 128 172)
cTARGETS=(../icons/RESXxRESY)
render_batch

cNAME="theme icons"
cITEMS=(icon-cover-{todo,ignored,done}@24
        icon-m-{todo,ignored,done}@112
        icon-m-enter-add@112
        "$cMY_APP@256"
)
cRESOLUTIONS=(F1)
cTARGETS=(../qml/images)
render_batch

cNAME="store icon"
cITEMS=("$cMY_APP")
cRESOLUTIONS=(172)
cTARGETS=(../dist)
render_batch

cNAME="banner image"
cITEMS=(../dist/banner)
cRESOLUTIONS=(
    1080x540++-large
    540x270++-small
)
cTARGETS=(../dist)
render_batch
