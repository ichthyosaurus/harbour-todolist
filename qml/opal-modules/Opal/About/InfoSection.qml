/*
 * This file is part of opal-about.
 * Copyright (C) 2020  Mirian Margiani
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * opal-about is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * opal-about is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with opal-about.  If not, see <http://www.gnu.org/licenses/>.
 *
 * *** CHANGELOG: ***
 *
 * 2020-08-22:
 * - initial release
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: item
    spacing: 0
    width: parent.width
    height: childrenRect.height

    property alias title: _titleLabel.text
    property string text: ""
    property string showMoreLabel: qsTr("show details")
    property alias button: _button
    property alias backgroundItem: _bgItem
    property alias enabled: _bgItem.enabled

    default property alias contentItem: _contents.children
    property alias _titleItem: _titleLabel
    property alias _textItem: _textLabel
    property alias _showMoreLabelItem: _showMoreLabel

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
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
                visible: text !== ""
                height: visible ? implicitHeight + Theme.paddingSmall : 0
            }

            Item {
                id: _contents
                width: parent.width
                height: childrenRect.height
            }

            Column {
                width: parent.width
                spacing: Theme.paddingMedium
                visible: item.text !== ""

                Label {
                    id: _textLabel
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: '<style type="text/css">A { color: "' +
                          String(Theme.primaryColor) +
                          '"; }</style>' + item.text
                    textFormat: Text.RichText
                }

                Row {
                    id: showMoreRow
                    anchors.right: parent.right
                    spacing: Theme.paddingSmall
                    visible: item.enabled && showMoreLabel !== ""
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
                height: item.text !== "" ? Theme.paddingMedium : 0
            }
        }
    }

    Item {
        width: 1
        height: _button.visible ? Theme.paddingMedium : 0
    }

    Button {
        id: _button
        anchors.horizontalCenter: parent.horizontalCenter
        visible: text !== ""
        height: visible ? implicitHeight : 0
    }
}
