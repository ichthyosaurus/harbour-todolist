/*
 * This file is part of harbour-todolist.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Opal.Delegates 1.0
import Opal.ComboData 1.0

PaddedDelegate {
    id: root

    readonly property bool canApply: !!text.trim()
    signal applied

    readonly property alias forDate: scheduledCombo.currentData
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
    rightItemAlignment: Qt.AlignTop
    padding.topBottom: 0

    Binding {
        target: main
        property: "hideTabBar"
        value: _textField.activeFocus
        when: !!_textField.activeFocus
    }

    Column {
        id: contentContainer
        width: parent.width
        spacing: Theme.paddingSmall

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

        ComboBox {
            id: scheduledCombo
            width: root.width
            x: -root.padding.effectiveLeft
            label: qsTr("Scheduled for")

            property date currentData
            ComboData { dataRole: "value" }

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("today")
                    property date value: today
                }
                MenuItem {
                    text: qsTr("tomorrow")
                    property date value: tomorrow
                }
                MenuItem {
                    text: qsTr("this week")
                    property date value: thisweek
                }
                MenuItem {
                    text: qsTr("someday")
                    property date value: someday
                }
            }
        }
    }

    rightItem: IconButton {
        enabled: root.canApply
        width: Theme.iconSizeSmallPlus
        icon.source: "image://theme/icon-splus-add"
        onClicked: root.apply()
    }

    onTextFieldFocusChanged: {
        if (!focus && canApply) {
            apply()
        }
    }
}
