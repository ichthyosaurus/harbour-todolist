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

TodoList {
    id: todoList
    model: filteredModel
    property int showFakeNavigation: FakeNavigation.None
    property int projectId

    header: FakeNavigationHeader {
        title: projectId ? qsTr("Tasks for project: ") + projectId : appName
        showNavigation: showFakeNavigation
    }

    function addItem() {
        var dialog = pageStack.push(addComponent, {
            date: lastSelectedCategory,
            project: projectId ? projectId : currentProjectId
        })
        dialog.accepted.connect(function() {
            main.addNormalTask(dialog.date, dialog.text.trim(), dialog.description.trim(), dialog.project);
            main.lastSelectedCategory = dialog.date
        });
    }

    Component {
        id: addComponent
        AddItemDialog {
            SectionHeader { text: qsTr("Note") }
            Label {
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                text: qsTr("Swipe left to add recurring entries. You can specify an interval "
                           + "in which they will be added automatically to the current to-do list.")
            }
        }
    }

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: currentEntriesModel

        sorters: [
            RoleSorter { roleName: "date"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "weight"; sortOrder: Qt.DescendingOrder }
        ]

        proxyRoles: [
            ExpressionRole {
                name: "_isYoung"
                expression: model.date >= today
            }
        ]

        filters: [
            ValueFilter {
                roleName: "_isYoung"
                value: true
            },
            ValueFilter {
                enabled: projectId
                roleName: "project"
                value: projectId
            }
        ]
    }

    PullDownMenu {
        MenuItem {
            text: qsTr("About")
            onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
        }
        MenuItem {
            text: qsTr("Show old entries")
            onClicked: pageStack.push(Qt.resolvedUrl("ArchivePage.qml"));
        }
        MenuItem {
            text: qsTr("Add entry")
            onClicked: addItem()
        }
    }

    footer: Spacer { }
}
