/*
 * This file is part of opal-about.
 * SPDX-FileCopyrightText: 2021 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

Column {
    property string title
    property bool headerVisible: title !== ''
    property list<License> licenses
    property var extraTexts: []
    property bool initiallyExpanded: false

    // Acknowledgements without licenses should be shown
    // on the contributors page but not on the licenses page.
    visible: licenses.length > 0
    width: parent.width
    height: childrenRect.height
    spacing: Theme.paddingSmall

    SectionHeader {
        visible: headerVisible
        text: title
    }

    Label {
        x: Theme.horizontalPageMargin
        visible: text !== ''
        width: parent.width - 2*x
        wrapMode: Text.Wrap
        text: extraTexts.join('; ')
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
        bottomPadding: Theme.paddingSmall
    }

    Repeater {
        model: licenses
        delegate: Column {
            id: licenseColumn
            width: parent.width
            spacing: Theme.paddingSmall

            property bool expanded: initiallyExpanded
            Behavior on height { SmoothedAnimation { duration: 150 } }

            BackgroundItem {
                height: Math.max(titleColumn.height, moreIcon.height+2*Theme.paddingSmall)
                width: parent.width
                onClicked: licenseColumn.expanded = !licenseColumn.expanded

                Row {
                    width: parent.width - Theme.horizontalPageMargin - Theme.paddingMedium
                    x: Theme.horizontalPageMargin
                    height: parent.height
                    spacing: Theme.paddingSmall

                    Column {
                        id: titleColumn
                        width: parent.width - moreIcon.width - parent.spacing
                        spacing: Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            text: modelData.name !== "" ? modelData.name : modelData.spdxId
                            topPadding: subtitle.visible ? Theme.paddingMedium : 0
                            height: implicitHeight
                            width: parent.width
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.fontSizeExtraSmall
                            wrapMode: Text.Wrap
                        }

                        Label {
                            id: subtitle
                            text: modelData.spdxId
                            visible: modelData.name !== ""
                            width: parent.width
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.fontSizeExtraSmall
                            wrapMode: Text.Wrap
                            palette.primaryColor: Theme.secondaryColor
                            bottomPadding: Theme.paddingMedium
                        }
                    }

                    HighlightImage {
                        id: moreIcon
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-m-right"
                        transformOrigin: Item.Center
                        rotation: licenseColumn.expanded ? 90 : 0
                        Behavior on rotation { SmoothedAnimation { duration: 25 } }
                    }
                }
            }

            Item {
                id: licenseTextContainer
                height: licenseColumn.expanded ? licenseTextLabel.height : 0
                width: parent.width - 2*Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: height > 0 ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation { duration: 150 } }
                clip: true

                Label {
                    id: licenseTextLabel
                    property bool error: modelData.error === true || modelData.fullText === ""
                    width: parent.width
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    textFormat: error ? Text.RichText : Text.PlainText
                    color: Theme.highlightColor

                    text: error ? '<style type="text/css">A { color: "' +
                                  String(Theme.primaryColor) +
                                  '"; }</style>' + qsTranslate("Opal.About", "Please refer to <a href='%1'>%1</a>").arg(
                                      "https://spdx.org/licenses/%1.html".arg(modelData.spdxId))
                                : modelData.fullText
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }
    }
}
