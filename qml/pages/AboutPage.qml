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

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property string appName: qsTr("Todo List")
    property string iconPath: "../images/harbour-todolist.png"
    property string versionNumber: VERSION_NUMBER
    property string description: qsTr("A simple tool for planning what to do next.")
    property string author: "Mirian Margiani"
    property string sourcesLink: "https://github.com/ichthyosaurus/harbour-todolist"
    property string sourcesText: qsTr("Sources on GitHub")
    property bool enableContributorsPage: false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            PageHeader {
                title: qsTr("About %1").arg(appName)
            }

            width: parent.width
            spacing: Theme.paddingLarge

            Image {
                x: (parent.width/2)-(Theme.itemSizeExtraLarge/2)
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                source: iconPath
                verticalAlignment: Image.AlignVCenter
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: String(qsTr("Version %1")).arg(versionNumber)
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                x: 2*Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: description
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeMedium
            }

            Item { width: parent.width; height: Theme.paddingMedium }
            BackgroundItem {
                anchors.left: parent.left; anchors.right: parent.right
                height: contributorsColumn.height
                onClicked: pageStack.push(Qt.resolvedUrl("ContributorsPage.qml"))
                enabled: enableContributorsPage

                Column {
                    id: contributorsColumn
                    x: Theme.horizontalPageMargin; width: parent.width - 2*x
                    spacing: Theme.paddingSmall

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: enableContributorsPage ? qsTr("Development") : qsTr("Author")
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeLarge
                    }
                    Item { width: parent.width; height: Theme.paddingMedium }
                    Label {
                        width: parent.width; horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap; font.pixelSize: Theme.fontSizeMedium
                        text: author
                    }
                    Row {
                        anchors.right: parent.right; spacing: Theme.paddingSmall
                        visible: enableContributorsPage
                        Label {
                            id: showContributorsLabel
                            textFormat: Text.StyledText; font.pixelSize: Theme.fontSizeExtraSmall
                            text: qsTr("<i>show contributors </i>")
                        }
                        Label { anchors.verticalCenter: showContributorsLabel.verticalCenter; text: "\u2022 \u2022 \u2022" } // three dots
                    }
                }
            }

            Item { width: parent.width; height: Theme.paddingMedium }
            BackgroundItem {
                anchors.left: parent.left; anchors.right: parent.right
                height: aboutColumn.height
                onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))

                Column {
                    id: aboutColumn
                    x: Theme.horizontalPageMargin; width: parent.width - 2*x
                    spacing: Theme.paddingSmall

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("License")
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeLarge
                    }
                    Item { width: parent.width; height: Theme.paddingMedium }
                    Label {
                        width: parent.width; horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap; font.pixelSize: Theme.fontSizeMedium
                        text: qsTr("GNU GPL version 3 or later.\n" +
                                   "This is free software: you are free to change and redistribute it."+
                                   "There is NO WARRANTY, to the extent permitted by law.")
                    }
                    Row {
                        anchors.right: parent.right; spacing: Theme.paddingSmall
                        Label {
                            id: showLicenseLabel
                            textFormat: Text.StyledText; font.pixelSize: Theme.fontSizeExtraSmall
                            text: qsTr("<i>show license </i>")
                        }
                        Label { anchors.verticalCenter: showLicenseLabel.verticalCenter; text: "\u2022 \u2022 \u2022" } // three dots
                    }
                }
            }

            Text {
                text: "<a href=\"%1\">%2</a>".arg(githubLink).arg(sourcesText)
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeMedium
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally(githubLink)
            }

            Item {
                id: bottomVerticalSpacing
                width: parent.width
                height: Theme.horizontalPageMargin
            }
        }
    }
}
