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

import QtQuick 2.2
import Sailfish.Silica 1.0
// import Sailfish.Silica.private 1.0 as Private
import "../components"

Dialog {
    id: dialog
    allowedOrientations: Orientation.All

    property date date: new Date(NaN)
    property alias text: textField.text
    property alias description: descriptionField.text
    property int project: currentProjectId
    property bool descriptionEnabled: true
    property alias predictiveHintsEnabled: predictionSwitch.checked
    property alias showProject: projectBox.visible

    default property alias contentColumn: column.children
    property alias titleText: titleLabel.text

    canAccept: text !== ""

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin
        VerticalScrollDecorator { flickable: flick }

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }
            spacing: 0

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Cancel")
            }

            Label {
                id: titleLabel
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                text: qsTr("Add an entry")
            }

            ComboBox {
                id: projectBox
                width: parent.width
                label: qsTr("Project")
                onCurrentItemChanged: {
                    if (!currentItem) return;
                    project = currentItem.entryId;
                }

                menu: ContextMenu {
                    Repeater {
                        model: projectsModel
                        MenuItem {
                            text: model.name
                            property int entryId: model.entryId
                            Component.onCompleted: {
                                if (entryId === project) projectBox.currentIndex = index;
                            }
                        }
                    }
                }
            }

            ComboBox {
                width: parent.width
                label: qsTr("Scheduled for")
                visible: currentIndex >= 0
                currentIndex: {
                    if (date.getTime() === today.getTime()) { return 0 }
                    else if (date.getTime() === tomorrow.getTime()) { return 1 }
                    else if (date.getTime() === thisweek.getTime()) { return 2 }
                    else if (date.getTime() === someday.getTime()) { return 3 }
                    else { return -1 }
                }

                menu: ContextMenu {
                    MenuItem { text: qsTr("today"); property date date: today; }
                    MenuItem { text: qsTr("tomorrow"); property date date: tomorrow; }
                    MenuItem { text: qsTr("this week"); property date date: thisweek; }
                    MenuItem { text: qsTr("someday"); property date date: someday; }
                }

                onCurrentItemChanged: {
                    dialog.date = currentItem.date;
                }
            }

            Spacer { }

            TextField {
                id: textField
                width: parent.width
                focus: true
                placeholderText: qsTr("Enter title")
                label: qsTr("Title")
                inputMethodHints: predictiveHintsEnabled ? Qt.ImhNone : Qt.ImhNoPredictiveText

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-" + (descriptionEnabled ? "next" : "accept")
                EnterKey.onClicked: {
                    if (descriptionEnabled) {
                        descriptionField.forceActiveFocus();
                    } else {
                        focus = false;
                        if (canAccept) accept();
                    }
                }

                // Error message: 'Unable to create a directory for the auto fill database.'
                // The AutoFill component is nowhere to be found, not even as an entry in
                // a qmldir file. It is probably defined in some plugin; it is part of the
                // private API anyway.
                // Note: if this component becomes publicly available, we should set different
                // keys for the different types of items (item, recurring, project).
                // Private.AutoFill {
                    // id: nameAutoFill
                    // key: "todolist.itemName"
                // }
            }

            TextSwitch {
                id: predictionSwitch
                text: qsTr("Enable predictive text input")
                checked: true
            }

            Spacer { height: Theme.paddingLarge }

            TextArea {
                id: descriptionField
                visible: descriptionEnabled
                width: parent.width
                placeholderText: qsTr("Enter optional description")
                label: qsTr("Description")
                inputMethodHints: predictiveHintsEnabled ? Qt.ImhNone : Qt.ImhNoPredictiveText
            }

            Spacer {
                visible: descriptionEnabled
            }
        }
    }
}
