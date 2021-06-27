/*
 * This file is part of harbour-todolist.
 *
 * SPDX-FileCopyrightText: 2020-2021 Mirian Margiani
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * harbour-todolist is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * harbour-todolist is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 *
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
    allowedOrientations: Orientation.All
    appName: main.appName
    iconSource: Qt.resolvedUrl("../images/harbour-todolist.png")
    versionNumber: APP_VERSION
    releaseNumber: APP_RELEASE
    description: qsTr("A simple tool for planning what to do next.")
    maintainer: "Mirian Margiani"
    sourcesUrl: "https://github.com/ichthyosaurus/harbour-todolist"

    licenses: License { spdxId: "GPL-3.0-or-later" }
    attributions: [
        Attribution {
            name: "Opal.About"
            entries: ["2018-2021 Mirian Margiani"]
            licenses: License { spdxId: "GPL-3.0-or-later" }
        },
        Attribution {
            name: "SortFilterProxyModel"
            entries: ["2016 Pierre-Yves Siret"]
            licenses: License { spdxId: "MIT" }
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
                ContributionGroup { title: qsTr("German"); entries: ["Mirian Margiani"]},
                ContributionGroup { title: qsTr("Norwegian"); entries: ["Øystein S. Haaland"]},
                ContributionGroup { title: qsTr("English"); entries: ["Mirian Margiani"]}
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
