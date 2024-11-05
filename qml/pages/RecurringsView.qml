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
import Opal.Tabs 1.0
import Opal.MenuSwitch 1.0
import "../components"
import "../js/helpers.js" as Helpers
import "../constants" 1.0

TabItem {
    id: root
    flickable: view

    SilicaListView {
        id: view
        model: recurringsModel
        anchors.fill: parent

        VerticalScrollDecorator { flickable: view }

        PullDownMenu {
            MenuSwitch {
                id: arrangeToggle
                text: qsTr("Arrange entries")
                checked: viewDragHandler.active
                automaticCheck: false
                onClicked: viewDragHandler.active = !viewDragHandler.active
            }

            MenuItem {
                text: qsTr("Add recurring entry")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddRecurringDialog.qml"))
                    dialog.accepted.connect(function() {
                        main.addRecurring(dialog.text.trim(), dialog.description.trim(), dialog.intervalDays, dialog.startDate);
                    });
                }
            }
        }

        header: Column {
            width: parent.width
            spacing: 0

            PageHeader {
                title: currentProjectName
            }

            Label {
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                color: Theme.secondaryHighlightColor
                text: qsTr("Configure recurring entries here. " +
                           "Active entries in this list are added " +
                           "automatically to the to-do list in " +
                           "regular intervals.")
            }
        }

        footer: Spacer { }

        IndexedListDragHandler {
            id: viewDragHandler
            active: false
            listView: view
        }

        delegate: TodoListBaseItem {
            editable: true
            descriptionEnabled: true
            infoMarkerEnabled: false
            text: model.text
            description: model.description
            dragHandler: viewDragHandler

            alwaysShowInterval: true
            editableInterval: true
            intervalProperty: "intervalDays"
            intervalStartProperty: "startDate"

            editableShowProject: true

            onMarkItemAs: main.updateRecurring(which, undefined, mainState);
            onSaveItemDetails: main.updateRecurring(which, undefined, undefined, undefined, newText, newDescription, newProject);
            onSaveItemRecurring: main.updateRecurring(which, startDate, undefined, interval, undefined, undefined);
            onDeleteThisItem: main.deleteRecurring(which, rowid)
            onMoveAndMarkItem: console.log("error: cannot 'move' recurring item")
            extraDeleteWarning: qsTr("This will <i>not</i> delete entries retroactively.")

            menu: Component {
                ContextMenu {
                    MenuItem {
                        visible: entryState !== EntryState.todo
                        text: qsTr("mark as active")
                        onClicked: markItemAs(index, EntryState.todo, undefined)
                    }
                    MenuItem {
                        visible: entryState !== EntryState.ignored
                        text: qsTr("mark as halted")
                        onClicked: markItemAs(index, EntryState.ignored, undefined)
                    }
                    MenuItem {
                        visible: entryState !== EntryState.done
                        text: qsTr("mark as done")
                        onClicked: markItemAs(index, EntryState.done, undefined)
                    }
                }
            }
        }

        section {
            property: 'entryState'
            delegate: Spacer {}
        }

        ViewPlaceholder {
            enabled: view.count == 0 && startupComplete
            text: qsTr("No entries yet")
            hintText: qsTr("This page will show a list of all recurring entries.")
        }
    }
}
