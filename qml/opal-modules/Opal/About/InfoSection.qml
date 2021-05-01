/*
 * This file is part of opal-about.
 * SPDX-FileCopyrightText: 2020-2021 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: root
    spacing: 0
    width: parent.width
    height: childrenRect.height

    property alias title: _titleLabel.text
    property string text: ""
    property string showMoreLabel: qsTranslate("Opal.About", "show details")
    property list<InfoButton> buttons
    property alias backgroundItem: _bgItem
    property alias enabled: _bgItem.enabled

    default property alias contentItem: _contents.children
    property alias _titleItem: _titleLabel
    property alias _textItem: _textLabel
    property alias _showMoreLabelItem: _showMoreLabel

    property list<DonationService> __donationButtons

    BackgroundItem {
        id: _bgItem

        enabled: false
        width: parent.width
        height: column.height

        Column {
            id: column
            width: parent.width - 2*Theme.horizontalPageMargin
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Label {
                id: _titleLabel
                width: parent.width
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeMedium
                visible: text !== ""
                height: visible ? implicitHeight + Theme.paddingSmall : 0
                color: Theme.highlightColor
            }

            Item {
                id: _contents
                width: parent.width
                height: childrenRect.height
            }

            Column {
                width: parent.width
                spacing: Theme.paddingMedium
                visible: root.text !== ""

                Label {
                    id: _textLabel
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.Wrap
                    text: '<style type="text/css">A { color: "' +
                          String(palette.secondaryColor) +
                          '"; }</style>' + root.text
                    textFormat: Text.RichText
                    palette.primaryColor: Theme.highlightColor
                }

                Row {
                    id: showMoreRow
                    anchors.right: parent.right
                    spacing: Theme.paddingSmall
                    visible: root.enabled && showMoreLabel !== ""
                    height: visible ? _showMoreLabel.height : 0

                    Label {
                        id: _showMoreLabel
                        textFormat: Text.StyledText; font.pixelSize: Theme.fontSizeExtraSmall
                        text: "<i>%1</i>".arg(showMoreLabel)
                    }
                    Label {
                        anchors.verticalCenter: _showMoreLabel.verticalCenter
                        text: " \u2022 \u2022 \u2022" // three dots
                    }
                }
            }

            Item {
                width: 1
                height: root.text !== "" ? Theme.paddingMedium : 0
            }
        }
    }

    Item {
        width: 1
        height: (buttons.length > 0 || __donationButtons.length > 0)
                ? Theme.paddingMedium : 0
    }

    Column {
        width: parent.width
        height: childrenRect.height
        spacing: Theme.paddingMedium

        Repeater {
            model: buttons
            delegate: Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width / 4 * 3
                height: visible ? implicitHeight : 0

                visible: modelData.text !== '' && modelData.enabled === true
                text: modelData.text
                onClicked: modelData.clicked()
            }
        }

        Repeater {
            model: __donationButtons
            delegate: Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width / 4 * 3
                height: visible ? implicitHeight : 0

                visible: modelData.name !== '' && modelData.url !== ''
                text: modelData.name
                onClicked: Qt.openUrlExternally(modelData.url)
            }
        }
    }
}
