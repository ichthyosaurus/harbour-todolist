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
 * 2020-08-22 [breaking]:
 * - packaged as part of Opal
 * - renamed to opal-about
 * - restructured and refactored
 *
 * 2020-06-16:
 * - make author section title and about page title configurable
 *
 * 2020-05-09:
 * - remove appName property (makes translations easier)
 *
 * 2020-04-25:
 * - remove version numbers, use changelog instead
 * - backwards-incompatible changes are marked with "[breaking]"
 *
 * 2020-04-24 [breaking]:
 * - make 'data' fields more usable as 'extra info' fields
 *
 * 2020-04-18:
 * - highlight missing version number
 *
 * 2020-04-17:
 * - initial release
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.About.private 1.0 as Private

Page {
    id: page
    allowedOrientations: Orientation.All

    property string appName: ""
    property string iconSource: ""      // e.g. Qt.resolvedUrl("../images/harbour-my-app.png")
                                        // or "/usr/share/icons/hicolor/172x172/apps/harbour-my-app.png"
    property string versionNumber: ""   // e.g. 'APP_VERSION' if configured via C++
    property string releaseNumber: ""   // optional, e.g. 'APP_RELEASE' if configured via C++
    property string description: ""     // a rich text description of the app
    property string author: ""          // the main author(s) or maintainer(s)
    property string sourcesUrl: ""      // where users can get the app's source code
    property list<InfoSection> extraSections
    property list<ContributionSection> contributionSections
    property list<License> licenses

    property alias flickable: _flickable
    property alias _pageHeaderItem: _pageHeader
    property alias _iconItem: _icon
    property alias _develInfoSection: _develInfo
    property alias _contribInfoSection: _contribInfo

    SilicaFlickable {
        id: _flickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            PageHeader {
                id: _pageHeader
                title: qsTr("About")
            }

            width: parent.width
            spacing: 1.5*Theme.paddingLarge

            Image {
                id: _icon
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                fillMode: Image.PreserveAspectFit
                source: iconSource
                verticalAlignment: Image.AlignVCenter
            }

            Column {
                width: parent.width - 2*Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall

                Label {
                    width: parent.width
                    visible: String(appName) !== ""
                    text: qsTr(appName)
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    width: parent.width
                    visible: String(versionNumber !== "")
                    text: qsTr("Version %1").arg(
                              String(releaseNumber === "1") ?
                                  versionNumber :
                                  versionNumber+"-"+releaseNumber)
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.horizontalPageMargin
                text: '<style type="text/css">A { color: "' +
                      String(Theme.primaryColor) +
                      '"; }</style>' + description
                onLinkActivated: Qt.openUrlExternally(link)
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
            }

            InfoSection {
                id: _develInfo
                width: parent.width
                title: enabled ? qsTr("Development") : qsTr("Author")
                enabled: contributionSections.length > 0
                text: author
                showMoreLabel: qsTr("show contributors")
                backgroundItem.onClicked: {
                    pageStack.animatorPush("Opal.About.private.ContributorsPage", {
                                               sections: contributionSections
                                           })
                }
            }

            Column {
                width: parent.width
                spacing: parent.spacing
                children: extraSections
            }

            InfoSection {
                id: _contribInfo
                width: parent.width
                title: qsTr("License")
                enabled: licenses.length > 0
                backgroundItem.onClicked: pageStack.animatorPush(
                                              "Opal.About.private.LicensePage",
                                              { licenses: licenses })
                text: enabled === false ?
                          qsTr("This is proprietary software. All rights reserved.") :
                          ((licenses[0].name !== "" && licenses[0].error !== true) ?
                               licenses[0].name + (licenses[0].customShortText === "" ?
                                                       "" :
                                                       "<br>"+licenses[0].customShortText) :
                               licenses[0].spdxId)
                showMoreLabel: qsTr("show license(s)", "", licenses.length)
                button.text: qsTr("Source Code")
                button.onClicked: Qt.openUrlExternally(sourcesUrl)
            }

            Item {
                id: bottomVerticalSpacing
                width: parent.width
                height: Theme.horizontalPageMargin
            }
        }
    }
}
