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

import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All
    property bool archiveReady: false

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: archiveModel

        sorters: [
            RoleSorter { roleName: "date"; sortOrder: Qt.DescendingOrder },
            RoleSorter { roleName: "entryState"; sortOrder: Qt.DescendingOrder },
            RoleSorter { roleName: "weight"; sortOrder: Qt.DescendingOrder }
        ]

        proxyRoles: [
            ExpressionRole {
                name: "_isOld"
                expression: model.date < today
            }
        ]

        filters: ValueFilter {
            roleName: "_isOld"
            value: true
        }
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: filteredModel
        height: contentHeight + Theme.paddingLarge
        VerticalScrollDecorator { flickable: view }

        header: PageHeader {
            title: currentProjectName
            description: qsTr("Archived Entries")
        }

        footer: Spacer { }

        delegate: TodoListItem {
            editable: false
            onCopyAndMarkItem: {
                main.addItem(copyToDate, title, description, mainState, subState, createdOn);
            }
        }

        section {
            property: 'date'
            delegate: SectionHeader {
                text: new Date(section).toLocaleString(Qt.locale(), main.fullDateFormat)
                height: Theme.itemSizeExtraSmall
            }
        }

        ViewPlaceholder {
            enabled: view.count == 0 && archiveReady
            text: qsTr("No entries yet")
            hintText: qsTr("This page will show a list of all old entries.")
        }
    }

    Component.onCompleted: {
        if (archiveModel.count === 0) {
            loadArchive();
        }
        archiveReady = true;
    }
}
