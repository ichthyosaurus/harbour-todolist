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
import SortFilterProxyModel 0.2
import "../components"
import "../js/helpers.js" as Helpers
import "../constants" 1.0

SilicaListView {
    id: view
    model: filteredModel
    VerticalScrollDecorator { flickable: view }
    property int showFakeNavigation: FakeNavigation.None

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: recurringsModel

        sorters: [
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "intervalDays"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "startDate"; sortOrder: Qt.AscendingOrder }
        ]
    }

    header: FakeNavigationHeader {
        title: qsTr("Recurring Entries")
        description: currentProjectName
        showNavigation: showFakeNavigation
    }

    PullDownMenu {
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

    footer: Spacer { }

    delegate: TodoListBaseItem {
        editable: true
        descriptionEnabled: true
        infoMarkerEnabled: false
        title: model.text
        description: model.description

        alwaysShowInterval: true
        editableInterval: true
        intervalProperty: "intervalDays"
        intervalStartProperty: "startDate"

        editableShowProject: true
        editableTitleText: qsTr("Edit recurring entry")

        onMarkItemAs: main.updateRecurring(view.model.mapToSource(which), undefined, mainState);
        onSaveItemDetails: main.updateRecurring(view.model.mapToSource(which), undefined, undefined, undefined, newText, newDescription, newProject);
        onSaveItemRecurring: main.updateRecurring(view.model.mapToSource(which), startDate, undefined, interval, undefined, undefined);
        onDeleteThisItem: main.deleteRecurring(view.model.mapToSource(which))
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
                MenuItem {
                    enabled: false
                    text: qsTr("press and hold to edit or delete")
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    _elideText: false
                    _fadeText: true
                }
            }
        }
    }

    section {
        property: 'entryState'
        delegate: Spacer { }
    }

    ViewPlaceholder {
        enabled: view.count == 0 && startupComplete
        text: qsTr("No entries yet")
        hintText: qsTr("This page will show a list of all recurring entries.")
    }
}
