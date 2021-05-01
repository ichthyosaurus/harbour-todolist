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
import "../components"

AddItemDialog {
    id: baseDialog
    allowedOrientations: Orientation.All
    date: new Date(NaN)
    titleText: qsTr("Edit entry")

    descriptionEnabled: true

    property bool showRecurring: false
    property bool editableRecurring: true

    property alias recurringStartDate: startDateButton.startDate
    property int recurringIntervalDays: intervalCombo.currentItem.value
    property int recurringInitialIntervalDays: 1

    property string extraDeleteWarning: ""

    // After ConfirmDeleteDialog was accepted,
    // this dialog will be accepted too, and requestDeletion
    // will be set to true. The parent then has to finish deleting the item.
    property bool requestDeletion: false

    IntervalCombo {
        id: intervalCombo
        currentIndex: recurringInitialIntervalDays
        visible: showRecurring
        enabled: editableRecurring
    }

    StartDateButton {
        id: startDateButton
        startDate: main.today
        visible: showRecurring && !isNaN(startDate.valueOf()) && recurringInitialIntervalDays !== 0
        enabled: editableRecurring && intervalCombo.currentIndex !== 0
    }

    Spacer { }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Delete")
        onClicked: {
            var dialog = pageStack.push(Qt.resolvedUrl("../pages/ConfirmDeleteDialog.qml"), {
                                            text: baseDialog.text,
                                            description: baseDialog.description,
                                            warning: baseDialog.extraDeleteWarning
                                        })
            dialog.accepted.connect(function() {
                requestDeletion = true;
                baseDialog.canAccept = true;
                baseDialog.accept();
            });
            dialog.rejected.connect(function() { requestDeletion = false; })
        }
    }

    onStatusChanged: if (requestDeletion && status === PageStatus.Active) baseDialog.accept();
}
