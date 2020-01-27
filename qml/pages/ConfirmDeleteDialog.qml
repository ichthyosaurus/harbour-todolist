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
    property string text
    property string description
    property bool _showDescription: description != ""
    property string warning: ""

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
                acceptText: qsTr("Delete")
                cancelText: qsTr("Cancel")
            }

            SectionHeader {
                text: qsTr("Text")
            }
            Label {
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                font.pixelSize: Theme.fontSizeMedium
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                text: dialog.text
            }

            SectionHeader {
                visible: _showDescription
                text: qsTr("Description")
            }
            Label {
                visible: _showDescription
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                font.pixelSize: Theme.fontSizeMedium
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                text: dialog.description
            }

            SectionHeader {
                visible: warning !== ""
                text: qsTr("Warning")
            }
            Label {
                visible: warning !== ""
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                font.pixelSize: Theme.fontSizeMedium
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                text: warning
                color: Theme.highlightColor
            }

            Spacer { }
        }
    }
}
