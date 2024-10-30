/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-FileCopyrightText: 2020 cage
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

.pragma library
.import Todolist.Constants 1.0 as Constants

function getDate(offset, baseDate) {
    var currentDate = baseDate === undefined ? new Date() : baseDate;
    currentDate.setDate(currentDate.getDate() + offset);
    currentDate.setHours(0, 0, 0, 0);
    return currentDate;
}

function getDateString(date) {
    return new Date(date).toLocaleString(Qt.locale(), "yyyy-MM-dd");
}

function indexForRowid(model, rowid, indexHint) {
    // Find the current index of an entry.
    // Give the last known index as indexHint to speed up searching.

    var rowidProperty = 'entryId'

    if (!model) {
        console.log("bug: indexForRowid got an invalid model", model)
        return -1
    }

    if (rowid === undefined) {
        console.log("bug: indexForRowid got an invalid rowid", rowid)
        return -1
    }

    if (indexHint !== undefined) {
        var item = model.get(indexHint)

        if (!!item && item[rowidProperty] === rowid) {
            return indexHint
        }
    }

    for (var i = 0; i < count; ++i) {
        if (model.get(i)[rowidProperty] === rowid) {
            return i
        }
    }

    console.warn("could not find entry with rowid", rowid,
                 "in model", model, "- last known index", indexHint)
    return -1
}
