//@ This file is part of opal-about.
//@ https://github.com/Pretty-SFOS/opal-about
//@ SPDX-FileCopyrightText: 2021-2022 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

Column {
    property string title
    property bool headerVisible: title !== ''
    property list<License> licenses
    property var extraTexts: []
    property bool initiallyExpanded: false

    property string description: ''  // optional
    property string homepage: ''  // optional
    property string sources: ''  // optional

    // Acknowledgements without licenses should be shown
    // on the contributors page but not on the licenses page,
    // unless they have a description.
    visible: licenses.length > 0 || description != ''
    width: parent.width
    height: childrenRect.height
    spacing: Theme.paddingSmall

    // Copy of AboutPageBase::openOrCopyUrl to ensure it is available.
    function openOrCopyUrl(externalUrl, title) {
        pageStack.push("ExternalUrlPage.qml", {'externalUrl': externalUrl, 'title': title})
    }

    SectionHeader {
        visible: headerVisible
        text: title
    }

    Label {
        x: Theme.horizontalPageMargin
        visible: description !== ''
        width: parent.width - 2*x
        wrapMode: Text.Wrap
        text: description
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
        bottomPadding: Theme.paddingSmall
        textFormat: Text.StyledText
        onLinkActivated: openOrCopyUrl(link)
        linkColor: palette.secondaryHighlightColor
        palette.primaryColor: Theme.highlightColor
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

    ButtonLayout {
        visible: homepage !== '' || sources !== ''

        Button {
            visible: homepage !== ''
            text: qsTranslate("Opal.About", "Homepage")
            onClicked: pageStack.push("ExternalUrlPage.qml", {'externalUrl': homepage})
        }

        Button {
            visible: sources !== ''
            text: qsTranslate("Opal.About", "Source Code")
            onClicked: pageStack.push("ExternalUrlPage.qml", {'externalUrl': sources})
        }
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
                height: licenseColumn.expanded ? textLoader.height : 0
                width: parent.width - 2*Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: height > 0 ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation { duration: 150 } }
                clip: true

                Loader {
                    id: textLoader
                    asynchronous: true
                    sourceComponent: Component {
                        Column {
                            width: licenseTextContainer.width
                            spacing: Theme.paddingMedium

                            Label {
                                visible: modelData.customShortText !== ''
                                text: modelData.customShortText + ' ―'
                                width: parent.width
                                wrapMode: Text.Wrap
                                font.pixelSize: Theme.fontSizeSmall
                                textFormat: Text.StyledText
                                palette.primaryColor: Theme.highlightColor
                                linkColor: Theme.primaryColor
                                onLinkActivated: pageStack.push("ExternalUrlPage.qml", {'externalUrl': link})
                            }

                            Label {
                                id: licenseTextLabel
                                property bool error: modelData.error === true || modelData.fullText === ""
                                width: parent.width
                                wrapMode: Text.Wrap
                                font.pixelSize: Theme.fontSizeExtraSmall
                                textFormat: error ? Text.StyledText : Text.PlainText
                                palette.primaryColor: Theme.highlightColor
                                linkColor: Theme.primaryColor
                                onLinkActivated: pageStack.push("ExternalUrlPage.qml", {'externalUrl': link})
                                text: error ? qsTranslate("Opal.About", "Please refer to <a href='%1'>%1</a>").arg(
                                                  "https://spdx.org/licenses/%1.html".arg(modelData.spdxId))
                                            : modelData.fullText
                            }
                        }
                    }
                }
            }
        }
    }
}
