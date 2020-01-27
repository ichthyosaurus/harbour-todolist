/*
 * This file is part of harbour-todolist.
 * Copyright (C) 2020  Mirian Margiani
 *
 * harbour-todolist is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-todolist is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-todolist.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

.pragma library

function getDate(offset, baseDate) {
    var currentDate = baseDate === undefined ? new Date() : baseDate;
    currentDate.setUTCDate(currentDate.getDate() + offset);
    currentDate.setUTCHours(0, 0, 0, 0);
    return currentDate;
}

function getDateString(date) {
    return new Date(date).toLocaleString(Qt.locale(), "yyyy-MM-dd");
}
