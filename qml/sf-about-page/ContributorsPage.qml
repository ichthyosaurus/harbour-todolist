/*
 * This file is part of sf-about-page.
 * Copyright (C) 2020  Mirian Margiani
 *
 * sf-about-page is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sf-about-page is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with sf-about-page.  If not, see <http://www.gnu.org/licenses/>.
 *
 * FILE VERSION: 1.0 (2020-04-17)
 *
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

/*
 * This page is automatically made available through AboutPage.qml.
 *
 * You don't have to configure this file. All properties are passed through
 * AboutPage.qml.
 *
 */
Page {
    property var development: []  // list of lists:
                                  // e.g.: [ {label: qsTr("Programming"), values: ["Jane Doe", "John Doe"]},
                                  //         {label: qsTr("Icon Desing"), values: ["Some Body", "Bodhi Sam"]}
                                  //       ]
    property var translations: [] // e.g.: [ {label: qsTr("English"), values: ["Jane Doe"]},
                                  //         {label: qsTr("Atlantean"), values: ["At Lanta"]}
                                  //       ]

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + 2*Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader { title: qsTr("Contributors") }

            SectionHeader { text: qsTr("Development") }

            Repeater {
                model: development
                delegate: DetailList {
                    label: modelData.label
                    values: modelData.values
                }
            }

            SectionHeader { text: qsTr("Translations") }

            Repeater {
                model: translations
                delegate: DetailList {
                    label: modelData.label
                    values: modelData.values
                }
            }
        }
    }
}
