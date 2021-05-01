/*
 * This file is part of opal-about.
 * SPDX-FileCopyrightText: 2021 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

.pragma library

function updateSpdxList(licenses, spdxTarget, force) {
    if (spdxTarget !== null && force !== true) {
        return null
    }

    var spdx = []

    for (var i in licenses) {
        spdx.push(licenses[i].spdxId)
    }

    return { spdx: spdx }
}
