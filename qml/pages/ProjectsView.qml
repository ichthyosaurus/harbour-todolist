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
import Opal.TabBar 1.0
import Opal.Delegates 1.0
import Opal.DragDrop 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../constants" 1.0

TabItem {
    id: root
    flickable: view

    SilicaListView {
        id: view
        model: filteredModel
        anchors.fill: parent
        cacheBuffer: 3 * Screen.height

        VerticalScrollDecorator { flickable: view }

        SortFilterProxyModel {
            id: filteredModel
            sourceModel: projectsModel
            sorters: [
                RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
                RoleSorter { roleName: "entryId"; sortOrder: Qt.AscendingOrder }
            ]
        }

        PullDownMenu {
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

//        ViewDragHandler {
//            id: viewDragHandler
//            active: true
//            listView: view
//        }

        delegate: TwoLineDelegate {
            id: delegate
            minContentHeight: Theme.itemSizeExtraSmall
            padding.topBottom: 0
            // dragHandler: viewDragHandler

            property bool _isArchivedEntry: typeof(_isOld) !== 'undefined'
                                            && _isOld === true
            property real contentOpacity: _isArchivedEntry ?
                1-baseOpacity : baseOpacity
            property real baseOpacity: {
                if (entryState === EntryState.Todo) {
                    1.0
                } else if (entryState === EntryState.Ignored) {
                    0.7
                } else if (entryState === EntryState.Done) {
                    0.6
                }
            }

            text: model.name
            textLabel.opacity: contentOpacity
            descriptionLabel.opacity: contentOpacity
            highlighted: down || main.configuration.currentProject === model.entryId

            leftItem: DelegateIconButton {
                id: checkbox

                Binding on highlighted {
                    when: delegate.highlighted
                    value: true
                }

                opacity: 0.7 * _delegate.contentOpacity
                iconSize: Theme.iconSizeMedium
                iconSource: {
                    if (entryState === EntryState.Todo) {
                        Qt.resolvedUrl("../images/icon-m-todo.png")
                    } else if (entryState === EntryState.Ignored) {
                        Qt.resolvedUrl("../images/icon-m-ignored.png")
                    } else if (entryState === EntryState.Done) {
                        Qt.resolvedUrl("../images/icon-m-done.png")
                    }
                }
            }

            onClicked: {
                if (main.configuration.currentProject !== model.entryId) {
                    main.setCurrentProject(model.entryId)
                }
            }
        }

/*
        delegate: TodoListBaseItem {
            id: item
            editable: true
            deletable: entryId !== defaultProjectId
            descriptionEnabled: false
            infoMarkerEnabled: false
            title: model.name
            highlighted: main.configuration.currentProject === entryId

            onMarkItemAs: main.updateProject(view.model.mapToSource(which), undefined, mainState);
            onSaveItemDetails: main.updateProject(view.model.mapToSource(which), newText, undefined);
            onDeleteThisItem: main.deleteProject(view.model.mapToSource(which))
            onMoveAndMarkItem: console.log("error: cannot 'move' project")
            extraDeleteWarning: qsTr("All entries belonging to this project will be deleted!")

            editableShowProject: false

            customClickHandlingEnabled: true
            showMenuOnPressAndHold: true
            onClicked: {
                if (main.configuration.currentProject !== entryId) {
                    main.setCurrentProject(entryId);
                }
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
        */

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
