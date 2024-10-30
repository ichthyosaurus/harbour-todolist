/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.TabBar 1.0
import SortFilterProxyModel 0.2
import "../components"

TabItem {
    id: root
    flickable: todoList

    TodoList {
        id: todoList
        model: filteredModel
        anchors.fill: parent

        header: Column {
            width: parent.width

            PageHeader {
                title: currentProjectName
            }

            TodoListItemAdder {
                id: adder
                forDate: main.today
                leftItem: null
                onApplied: {
                    textField.forceActiveFocus()
                    focusTimer.restart()
                }

                Timer {
                    id: focusTimer
                    interval: 80
                    onTriggered: {
                        adder.textField.forceActiveFocus()
                    }
                }
            }
        }

        function addItem() {
            var dialog = pageStack.push(addComponent, { date: lastSelectedCategory })
            dialog.accepted.connect(function() {
                main.addItem(dialog.date, dialog.text.trim(), dialog.description.trim());
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
                },
                ExpressionRole {
                    name: "category"
                    expression: {
                        var string = new Date(model.date).toLocaleString(Qt.locale(), "yyyy-MM-dd")
                        if (string == main.todayString) "today"
                        else if (string == main.tomorrowString) "tomorrow"
                        else if (string == main.thisweekString) "thisweek"
                        else if (string == main.somedayString) "someday"
                        else ""
                     }
                }
            ]

            filters: ValueFilter {
                roleName: "_isYoung"
                value: true
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Show old entries")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("ArchivePage.qml"));
            }
            MenuItem {
                text: qsTr("Add entry")
                onClicked: todoList.addItem()
            }
        }

        footer: Spacer { }
    }
}
