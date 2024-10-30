/*
 * This file is part of harbour-todolist.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Opal.Delegates 1.0

PaddedDelegate {
    id: root

    readonly property bool canApply: !!text.trim()
    signal applied

    property date forDate
    property alias text: _textField.text
    property TextField textField: _textField
    property alias acceptableInput: _textField.acceptableInput
    signal textFieldFocusChanged(var focus)

    function apply() {
        if (canApply) {
            main.addItem(forDate, text.trim(), '')
            text = ''
            textField.forceActiveFocus()
            applied()
        }
    }

    minContentHeight: Theme.itemSizeSmall
    centeredContainer: contentContainer
    interactive: false
    padding.topBottom: 0

    Column {
        id: contentContainer
        width: parent.width

        TextField {
            id: _textField
            width: parent.width
            textMargin: 0
            textTopPadding: 0
            labelVisible: false
            EnterKey.onClicked: {
                if (canApply) apply()
                else textField.focus = false
            }
            EnterKey.iconSource: root.canApply ?
                 "../images/icon-m-enter-add.png" :
                 "image://theme/icon-m-enter-close"
            onActiveFocusChanged: textFieldFocusChanged(activeFocus)
        }
    }

    rightItem: IconButton {
        enabled: root.canApply
        width: Theme.iconSizeSmallPlus
        icon.source: "image://theme/icon-splus-add"
        onClicked: root.apply()
    }

    leftItem: Item {
        width: Theme.iconSizeSmallPlus
        height: 1
    }

    onTextFieldFocusChanged: {
        if (!focus && canApply) {
            apply()
        }
    }
}
