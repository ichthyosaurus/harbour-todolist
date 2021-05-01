/*
 * This file is part of harbour-todolist.
 *
 * SPDX-FileCopyrightText: 2020 Mirian Margiani
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

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../js/helpers.js" as Helpers

ValueButton {
    property date startDate

    label: qsTr("Starting at")
    value: startDate.toLocaleString(Qt.locale(), main.fullDateFormat)

    onClicked: {
        var dialog = pageStack.push(pickerComponent, { date: startDate })
        dialog.accepted.connect(function() {
            startDate = Helpers.getDate(0, dialog.date);
        })
    }

    Component {
        id: pickerComponent
        DatePickerDialog {}
    }
}
