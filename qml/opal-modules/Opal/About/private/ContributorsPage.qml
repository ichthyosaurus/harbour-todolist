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
 * 2020-04-25:
 * - remove version numbers, use changelog instead
 * - backwards-incompatible changes are marked with "[breaking]"
 * - allow all page orientations (effective value is limited by ApplicationWindow.allowedOrientations)
 *
 * 2020-04-24:
 * - hide empty groups
 *
 * 2020-04-17:
 * - initial release
 *
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import Opal.About 1.0

Page {
    allowedOrientations: Orientation.All
    property list<ContributionSection> sections

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + 2*Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader { title: qsTr("Contributors") }

            Repeater {
                model: sections
                delegate: Column {
                    width: parent.width
                    spacing: column.spacing

                    SectionHeader {
                        text: modelData.title
                        visible: modelData.groups.length > 0
                    }

                    Repeater {
                        model: modelData.groups
                        delegate: DetailList {
                            label: modelData.title
                            values: modelData.entries
                        }
                    }
                }
            }
        }
    }
}
