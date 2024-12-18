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
import "../constants" 1.0

import "../js/storage.js" as Storage

TabItem {
    id: root
    flickable: view

    property bool arrangeEntries: arrangeToggle.checked

    SilicaListView {
        id: view
        model: projectsModel
        anchors.fill: parent
        cacheBuffer: 3 * Screen.height

        VerticalScrollDecorator { flickable: view }

        PullDownMenu {
            MenuSwitch {
                id: arrangeToggle
                text: qsTr("Arrange entries")
            }

            MenuItem {
                text: qsTr("Add project")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), {
                        date: new Date(NaN), descriptionEnabled: false,
                        titleText: qsTr("Add a project"),
                        showProject: false
                    })
                    dialog.accepted.connect(function() {
                        main.addProject(dialog.text.trim())
                    });
                }
            }
        }

        header: PageHeader {
            title: qsTr("Projects")
        }

        footer: Spacer { }

        IndexedListDragHandler {
            id: viewDragHandler
            active: arrangeEntries
            listView: view
        }

        delegate: TodoListBaseItem {
            id: item
            text: model.name
            highlighted: down || main.configuration.currentProject === model.entryId
            dragHandler: viewDragHandler

            editable: true
            deletable: entryId !== defaultProjectId
            descriptionEnabled: false
            infoMarkerEnabled: false
            intervalProperty: "dueToday"
            alwaysShowInterval: dueToday > 0

            onMarkItemAs: main.updateProject(which, undefined, mainState);
            onSaveItemDetails: main.updateProject(which, newText, undefined);
            onDeleteThisItem: main.deleteProject(which, rowid)
            onMoveAndMarkItem: console.log("error: cannot 'move' project")
            extraDeleteWarning: qsTr("All entries belonging to this project will be deleted!")

            editableShowProject: false

            customClickHandlingEnabled: true
            showMenuOnPressAndHold: true
            onClicked: {
                if (main.configuration.currentProject !== model.entryId) {
                    main.setCurrentProject(model.entryId)
                }
            }
            onCheckboxClicked: {
                openMenu()
            }

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
                        text: qsTr("mark as finished")
                        onClicked: markItemAs(index, EntryState.done, undefined)
                    }
                    MenuItem {
                        visible: editable
                        text: deletable ? qsTr("edit or delete") : qsTr("edit")
                        onClicked: startEditing()
                    }
                }
            }
        }

        section {
            property: 'entryState'
            delegate: Spacer {
                    height: y == 0 ? 0 : 2*Theme.paddingLarge
            }
        }

        ViewPlaceholder {
            enabled: view.count == 0
            text: qsTr("No entries")
            hintText: qsTr("This should not be possible. Most probably a database error occurred.")
        }
    }
}
