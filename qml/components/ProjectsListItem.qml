/*
 * This file is part of harbour-todolist.
 *
 * SPDX-FileCopyrightText: 2020-2021 Mirian Margiani
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../constants" 1.0

ListItem {
    id: item
    width: ListView.view.width
    contentHeight: row.height
    ListView.onRemove: animateRemoval(item) // enable animated list item removals

    property string title: ""
    property string description: ""
    property int project: currentProjectId
    property string extraDeleteWarning: ""
    property bool editable: true
    property bool deletable: true
    property bool descriptionEnabled: false
    property bool editableShowProject: false
    property bool editableInterval: false
    property string intervalProperty: "interval"
    property string intervalStartProperty: "date"

    property bool _isArchivedEntry: typeof(_isOld) !== 'undefined' && _isOld === true

    signal markItemAs(var which, var mainState, var subState)
    signal copyAndMarkItem(var which, var mainState, var subState, var copyToDate)
    signal moveAndMarkItem(var which, var mainState, var subState, var moveToDate)
    signal saveItemDetails(var which, var newText, var newDescription, var newProject)
    signal deleteThisItem(var which)

    showMenuOnPressAndHold: false

    function startEditing() {
        var dialog = pageStack.push(Qt.resolvedUrl("../pages/EditItemDialog.qml"), {
            text: title,
            description: description,
            descriptionEnabled: descriptionEnabled,
            showRecurring: model[intervalProperty] !== undefined,
            editableRecurring: editableInterval,
            recurringStartDate: model[intervalStartProperty] !== undefined ? model[intervalStartProperty] : new Date(NaN),
            recurringInitialIntervalDays: model[intervalProperty] !== undefined ? model[intervalProperty] : 0,
            extraDeleteWarning: extraDeleteWarning,
            showProject: editableShowProject,
            project: project
        });
        dialog.accepted.connect(function() {
            if (dialog.requestDeletion) {
                deleteThisItem(index);
            } else {
                saveItemDetails(index, dialog.text.trim(), dialog.description.trim(), dialog.project);
                if (editableInterval) saveItemRecurring(index, dialog.recurringIntervalDays, dialog.recurringStartDate);
            }
        });
    }

    Connections {
        target: item
        onPressAndHold: if (editable) startEditing();
        onClicked: menu ? openMenu() : {}
    }

    Row {
        id: row
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            topMargin: Theme.paddingMedium
            bottomMargin: Theme.paddingMedium
        }
        height: Math.max(textColumn.height, statusIcon.height+2*Theme.paddingMedium)
        spacing: Theme.paddingMedium

        HighlightImage {
            id: statusIcon
            opacity: Theme.opacityHigh
            highlighted: item.highlighted
            width: Theme.iconSizeSmallPlus
            height: width
            color: Theme.primaryColor
            anchors.top: parent.top
            anchors.topMargin: parent.anchors.topMargin
        }

        Column {
            id: textColumn
            anchors.top: parent.top
            width: parent.width - statusIcon.width - spacing

            Spacer { height: Theme.paddingMedium }

            Label {
                width: parent.width
                text: title
                font.pixelSize: Theme.fontSizeMedium
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
            }

            Spacer { height: Theme.paddingMedium }
        }
    }

    states: [
        State {
            name: "todo"
            when: _isArchivedEntry === false && entryState === EntryState.todo
            PropertyChanges { target: statusIcon; source: "../images/icon-todo.png"; opacity: Theme.opacityHigh }
        },
        State {
            name: "ignored"
            when: _isArchivedEntry === false && entryState === EntryState.ignored
            PropertyChanges { target: statusIcon; source: "../images/icon-ignored.png"; }
            PropertyChanges { target: row; opacity: Theme.opacityHigh }
        },
        State {
            name: "done"
            when: _isArchivedEntry === false && entryState === EntryState.done
            PropertyChanges { target: statusIcon; source: "../images/icon-done.png"; }
            PropertyChanges { target: row; opacity: Theme.opacityLow }
        },
        State {
            name: "todoArchived"
            when: _isArchivedEntry === true && entryState === EntryState.todo
            PropertyChanges { target: statusIcon; source: "../images/icon-todo.png"; }
            PropertyChanges { target: row; opacity: Theme.opacityLow }
        },
        State {
            name: "ignoredArchived"
            when: _isArchivedEntry === true && entryState === EntryState.ignored
            PropertyChanges { target: statusIcon; source: "../images/icon-ignored.png"; }
            PropertyChanges { target: row; opacity: Theme.opacityHigh }
        },
        State {
            name: "doneArchived"
            when: _isArchivedEntry === true && entryState === EntryState.done
            PropertyChanges { target: statusIcon; source: "../images/icon-done.png"; opacity: Theme.opacityHigh }
        }
    ]
}
