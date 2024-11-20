/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

AddItemDialog {
    SectionHeader {
        text: qsTr("Note")
    }

    Label {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }

        wrapMode: Text.WordWrap
        color: Theme.highlightColor
        text: qsTr("Swipe left to add recurring entries. " +
                   "You can specify an interval " +
                   "in which they will be added automatically " +
                   "to the current to-do list.")
    }
}
