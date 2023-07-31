/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2022 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * Translators:
 * Please add yourself to the list of contributors below. If your language is already
 * in the list, add your name to the 'entries' field. If you added a new translation,
 * create a new section at the top of the list.
 *
 * Other contributors:
 * Please add yourself to the relevant list of contributors.
 *
 * <...>
 *  ContributionGroup {
 *      title: qsTr("Your language")
 *      entries: ["Existing contributor", "YOUR NAME HERE"]
 *  },
 * <...>
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.About 1.0

AboutPageBase {
    id: page
    appName: main.appName
    appIcon: Qt.resolvedUrl("../images/harbour-todolist.png")
    appVersion: APP_VERSION
    appRelease: APP_RELEASE
    description: qsTr("A simple tool for planning what to do next.")
    mainAttributions: "2020-2022 Mirian Margiani"
    sourcesUrl: "https://github.com/ichthyosaurus/harbour-todolist"
    homepageUrl: "https://openrepos.net/content/ichthyosaurus/todolist"

    licenses: License { spdxId: "GPL-3.0-or-later" }
    attributions: [
        Attribution {
            name: "SortFilterProxyModel"
            entries: ["2016 Pierre-Yves Siret"]
            licenses: License { spdxId: "MIT" }
            sources: "https://github.com/oKcerG/SortFilterProxyModel"
        },
        OpalAboutAttribution { }
    ]

    contributionSections: [
        ContributionSection {
            title: qsTr("Development")
            groups: [
                ContributionGroup {
                    title: qsTr("Programming")
                    entries: ["Mirian Margiani", "Johannes Bachmann", "Øystein S. Haaland"]
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
                ContributionGroup { title: qsTr("Polish"); entries: ["atlochowski", "likot180"] },
                ContributionGroup { title: qsTr("Swedish"); entries: ["Åke Engelbrektson"]},
                ContributionGroup { title: qsTr("Chinese"); entries: ["dashinfantry"]},
                ContributionGroup { title: qsTr("German"); entries: ["Mirian Margiani"]},
                ContributionGroup { title: qsTr("Norwegian"); entries: ["Øystein S. Haaland"]},
                ContributionGroup { title: qsTr("English"); entries: ["Mirian Margiani"]},
                ContributionGroup { title: qsTr("Russian"); entries: ["Nikolay Sinyov"]}
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
