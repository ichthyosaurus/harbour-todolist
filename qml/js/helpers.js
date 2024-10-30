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
