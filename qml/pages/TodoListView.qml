/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.Tabs 1.0
import Opal.MenuSwitch 1.0
import SortFilterProxyModel 0.2
import "../components"

TabItem {
    id: root
    flickable: todoList

    TodoList {
        id: todoList
        model: currentEntriesModel
        anchors.fill: parent

        header: Column {
            width: parent.width

            PageHeader {
                title: currentProjectName
            }

            TodoListItemAdder {
                id: adder
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
            var dialog = pageStack.push(
                Qt.resolvedUrl("AddRegularDialog.qml"),
                { date: lastSelectedCategory })
            dialog.accepted.connect(function() {
                main.addItem(dialog.date, dialog.text.trim(), dialog.description.trim());
                main.lastSelectedCategory = dialog.date
            });
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("About and Archive",
                           "as in “show me the 'About page' and " +
                           "the 'Archive page'”")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuSwitch {
                id: arrangeToggle
                text: qsTr("Arrange entries")
                checked: todoList.viewDragHandler.active
                automaticCheck: false
                onClicked: todoList.viewDragHandler.active =
                           !todoList.viewDragHandler.active
            }
            MenuItem {
                text: qsTr("Add entry")
                onClicked: todoList.addItem()
            }
        }

        footer: Spacer { }
    }
}
