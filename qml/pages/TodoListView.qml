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

import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../constants" 1.0

TodoList {
    id: todoList
    model: filteredModel
    property int showFakeNavigation: FakeNavigation.None

    header: FakeNavigationHeader {
        title: currentProjectName
        description: qsTr("Todo List")
        showNavigation: showFakeNavigation
    }

    function addItemFor(date) {
        var dialog = pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), { date: date })
        dialog.accepted.connect(function() {
            addItem(date, dialog.text.trim(), dialog.description.trim());
        });
    }

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: rawModel

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

        filters: ValueFilter {
            roleName: "_isYoung"
            value: true
        }
    }

    PullDownMenu {
        MenuItem {
            text: qsTr("Add entry for someday")
            onClicked: addItemFor(someday)
        }
        MenuItem {
            text: qsTr("Add entry for tomorrow")
            onClicked: addItemFor(tomorrow)
        }
        MenuItem {
            text: qsTr("Add entry for today")
            onClicked: addItemFor(today)
        }
    }

    PushUpMenu {
        MenuItem {
            text: qsTr("Show old entries")
            onClicked: pageStack.push(Qt.resolvedUrl("ArchivePage.qml"));
        }
        MenuItem {
            text: qsTr("About")
            onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
        }
    }

    footer: Spacer { }
}
