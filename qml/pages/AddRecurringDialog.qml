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

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"
import "../js/helpers.js" as Helpers

AddItemDialog {
    date: new Date(NaN)
    descriptionEnabled: true

    property bool enableStartDate: true
    property date startDate: main.today
    property int intervalDays: intervalCombo.currentItem.value
    property int defaultInterval: 1

    ComboBox {
        id: intervalCombo
        width: parent.width
        label: qsTr("Recurring")
        currentIndex: defaultInterval

        menu: ContextMenu {
            Repeater {
                model: 61
                delegate: MenuItem {
                    text: index === 0 ? qsTr("once", "interval for recurring entries")
                                      : qsTr("every %n day(s)", "interval for recurring entries", index)
                    property int value: index
                }
            }
        }
    }

    ValueButton {
        enabled: enableStartDate && intervalCombo.currentIndex !== 0
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
}
