/*
 * This file is part of harbour-todolist.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Mirian Margiani
 *
 * Translators:
 * Please add yourself to the list of contributors below. If your language is already
 * in the list, add your name to the 'entries' field. If you added a new translation,
 * create a new section at the top of the list.
 *
 * <...>
 *  ContributionGroup {
 *      title: qsTr("Your language")
 *      entries: ["Existing contributor", "YOUR NAME HERE"]
 *  },
 * <...>
 *
 * Other contributors:
 * Please add yourself to the relevant list of contributors.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.About 1.0

AboutPageBase {
    id: page
    allowedOrientations: Orientation.All
    appName: main.appName
    iconSource: Qt.resolvedUrl("../images/harbour-todolist.png")
    versionNumber: APP_VERSION
    releaseNumber: APP_RELEASE
    description: qsTr("A simple tool for planning what to do next.")
    author: "Mirian Margiani"
    sourcesUrl: "https://github.com/ichthyosaurus/harbour-todolist"
    licenses: [
        License {
            spdxId: "GPL-3.0-or-later"
            // customShortText: "This is free software: you are free to change and redistribute it. " +
            //                  "There is NO WARRANTY, to the extent permitted by law."
            forComponents: ["harbour-todolist", "Opal.About"]
        },
        License {
            spdxId: "MIT"
            forComponents: ["SortFilterProxyModel"]
        }
    ]

    contributionSections: [
        ContributionSection {
            title: qsTr("Development")
            groups: [
                ContributionGroup {
                    title: qsTr("Programming")
                    entries: ["Mirian Margiani", "Johannes Bachmann"]
                }/*,
                ContributionGroup {
                    title: qsTr("Icon Design")
                    entries: ["Mirian Margiani"]
                }*/
            ]
        },
        ContributionSection {
            title: qsTr("Translations")
            groups: [
                ContributionGroup { title: qsTr("Polish"); entries: ["atlochowski"] },
                ContributionGroup { title: qsTr("Swedish"); entries: ["Åke Engelbrektson"]},
                ContributionGroup { title: qsTr("Chinese"); entries: ["dashinfantry"]},
                ContributionGroup { title: qsTr("German"); entries: ["Mirian Margiani"]}/*,
                ContributionGroup { title: qsTr("English"); entries: ["Mirian Margiani"]}*/
            ]
        },
        ContributionSection {
            title: qsTr("Third party libraries")
            groups: [
                ContributionGroup {
                    title: "SortFilterProxyModel"
                    entries: ["Pierre-Yves Siret"]
                },
                ContributionGroup {
                    title: "Opal.About"
                    entries: ["Mirian Margiani"]
                }
            ]
        }
    ]

    /*PullDownMenu {
        parent: page.flickable
        MenuItem {
            text: qsTr("Import from other apps")
            onClicked: console.warn("not yet implemented")
        }
        MenuItem {
            text: qsTr("Export data")
            onClicked: console.warn("not yet implemented")
        }
    }*/
}