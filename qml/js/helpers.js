/*
 * This file is part of harbour-todolist.
 *
 * SPDX-FileCopyrightText: 2020 Mirian Margiani
 * SPDX-FileCopyrightText: 2020 cage
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * harbour-todolist is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * harbour-todolist is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */

.pragma library

function getDate(offset, baseDate) {
    var currentDate = baseDate === undefined ? new Date() : baseDate;
    currentDate.setDate(currentDate.getDate() + offset);
    currentDate.setHours(0, 0, 0, 0);
    return currentDate;
}

function getDateString(date) {
    return new Date(date).toLocaleString(Qt.locale(), "yyyy-MM-dd");
}
