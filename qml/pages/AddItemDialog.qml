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
    property date date: main.today
    property alias text: textField.text
    property alias description: descriptionField.text
    property bool descriptionEnabled: true

    default property alias contentColumn: column.children

    canAccept: text !== ""

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: flick }

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }

            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Cancel")
            }

            Label {
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                text: {
                    if (date.getTime() === today.getTime()) {
                        qsTr("Add entry for today");
                    } else if (date.getTime() === tomorrow.getTime()) {
                        qsTr("Add entry for tomorrow");
                    } else if (date.getTime() === someday.getTime()) {
                        qsTr("Add entry for someday");
                    } else {
                        qsTr("Add entry");
                    }
                }
            }

            Label {
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                text: currentProjectName
            }

            Spacer { }

            TextField {
                id: textField
                width: parent.width
                focus: true
                placeholderText: qsTr("Enter title")
                label: qsTr("Title")
                // inputMethodHints: Qt.ImhNoPredictiveText

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

            Spacer { }

            TextArea {
                id: descriptionField
                visible: descriptionEnabled
                width: parent.width
                placeholderText: qsTr("Enter optional description")
                label: qsTr("Description")
            }

            Spacer {
                visible: descriptionEnabled
            }
        }
    }
}
