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
import "../constants" 1.0

SilicaListView {
    id: view
    model: filteredModel
    VerticalScrollDecorator { flickable: view }
    property int showFakeNavigation: FakeNavigation.None

    PullDownMenu {
        MenuItem {
            text: qsTr("Add project")
            onClicked: {
                var dialog = pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), {
                    date: new Date(NaN),
                    descriptionEnabled: false,
                    showProject: false
                })
                dialog.accepted.connect(function() {
                    main.addProject(dialog.text.trim());
                });
            }
        }
    }

    header: FakeNavigationHeader {
        title: qsTr("Projects")
        showNavigation: showFakeNavigation
    }

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: projectsModel
        sorters: [
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "entryId"; sortOrder: Qt.AscendingOrder }
        ]
    }

    footer: Spacer { }

    function projectIsActive(projectId) {
        return main.configuration.activeProjects.indexOf(projectId) !== -1
    }

    delegate: ProjectsListItem {
        id: item
        deletable: entryId !== defaultProjectId
        title: model.name
        highlighted: projectIsActive(entryId)

        onMarkItemAs: main.updateProject(view.model.mapToSource(which), undefined, mainState);
        onSaveItemDetails: main.updateProject(view.model.mapToSource(which), newText, undefined);
        onDeleteThisItem: main.deleteProject(view.model.mapToSource(which))
        onMoveAndMarkItem: console.log("error: cannot 'move' project")
        extraDeleteWarning: qsTr("All entries belonging to this project will be deleted!")

        onClicked: {
            var projIndex = main.configuration.activeProjects.indexOf(entryId)
            if (projIndex === -1) {
                main.configuration.activeProjects.push(entryId)
            } else {
                main.configuration.activeProjects.splice(projIndex, 1)
            }
            item.highlighted = projectIsActive(entryId)
            main.updateProjectEntries()
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
        delegate: Spacer { }
    }

    ViewPlaceholder {
        enabled: view.count == 0
        text: qsTr("No entries")
        hintText: qsTr("This should not be possible. Most probably a database error occurred.")
    }
}
