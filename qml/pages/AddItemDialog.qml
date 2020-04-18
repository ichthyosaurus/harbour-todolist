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

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"

Dialog {
    id: dialog
    allowedOrientations: Orientation.All

    property date date: new Date(NaN)
    property alias text: textField.text
    property alias description: descriptionField.text
    property bool descriptionEnabled: true
    property alias predictiveHintsEnabled: predictionSwitch.checked
    property alias showProject: project.visible

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

            spacing: 0//Theme.paddingMedium

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

            ComboBox {
                id: project
                width: parent.width
                label: qsTr("Project")
                currentIndex: 0
                enabled: false

                menu: ContextMenu {
                    MenuItem { text: currentProjectName }
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
            }

            TextSwitch {
                id: predictionSwitch
                text: "Enable predictive text"
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
