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
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../constants" 1.0
import "../js/helpers.js" as Helpers

SilicaListView {
    id: view
    VerticalScrollDecorator { flickable: view }

    readonly property var defaultClosedSections: [somedayString]
    property var closedSections: defaultClosedSections.slice()
    signal sectionToggled(var whichSection)

    Connections {
        target: main.configuration
        onValueChanged: if (key === "currentProject") closedSections = defaultClosedSections.slice()
    }

    delegate: TodoListItem {
        id: listItem
        onMarkItemAs: updateItem(view.model.mapToSource(which), mainState, subState);
        onCopyAndMarkItem: {
            var sourceIndex = view.model.mapToSource(which);
            updateItem(sourceIndex, mainState, subState);
            main.copyItemTo(sourceIndex, copyToDate);
        }
        onSaveItemDetails: updateItem(view.model.mapToSource(which), undefined, undefined, newText, newDescription, newProject);
        onDeleteThisItem: deleteItem(view.model.mapToSource(which))
        onMoveAndMarkItem: {
            var sourceIndex = view.model.mapToSource(which);
            updateItem(sourceIndex, mainState, subState);
            moveItemTo(sourceIndex, moveToDate)
        }

        // To prevent a visual glitch when scrolling down a long list of items
        // while the last section is closed, we have to be careful what to
        // animate. We use an Item to declare a new state because it would
        // otherwise interfere with TodoListItem's states. We then activate
        // the transition once if the item's section was toggled.

        property string sectionString: Helpers.getDateString(date)

        Item {
            states: State {
                when: closedSections.indexOf(sectionString) !== -1
                name: "customHidden"
                PropertyChanges {
                    target: listItem
                    contentHeight: 0; enabled: false
                    opacity: 0.0
                }
            }
            transitions: Transition {
                NumberAnimation {
                    id: showHideAnimation
                    properties: "contentHeight, opacity"
                    duration: 0; onStopped: duration = 0
                }
            }
        }

        Connections {
            target: view
            onSectionToggled: if (whichSection === sectionString) showHideAnimation.duration = 200
        }
    }

    section {
        property: 'date'
        delegate: Column {
            width: parent.width
            property string sectionString: String(section).split("T")[0]
            property bool isToday: sectionString === todayString
            property bool isTomorrow: sectionString === tomorrowString
            property bool isThisWeek: sectionString === thisweekString
            property bool isSomeday: sectionString === somedayString
            property bool open: (closedSections.indexOf(sectionString) === -1)

            Spacer { height: Theme.paddingLarge }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall

                onClicked: {
                    sectionToggled(sectionString);
                    if (open) closedSections.push(sectionString);
                    else closedSections = closedSections.filter(function(e) { return e !== sectionString; });
                    closedSectionsChanged();
                }

                Label {
                    id: titleLabel
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        right: subtitleLabel.left
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    text: {
                        if (isToday) qsTr("Today")
                        else if (isTomorrow) qsTr("Tomorrow")
                        else if (isThisWeek) qsTr("This week")
                        else if (isSomeday) qsTr("Someday")
                        else new Date(section).toLocaleString(Qt.locale(), "dddd")
                    }
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }

                Label {
                    id: subtitleLabel
                    anchors {
                        right: moreImage.left
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    text: (isSomeday || isThisWeek) ? "" : new Date(section).toLocaleString(
                                          Qt.locale(), (isToday || isTomorrow) ?
                                              main.fullDateFormat : main.shortDateFormat)
                    color: Theme.highlightColor
                    opacity: Theme.opacityHigh
                    font.pixelSize: Theme.fontSizeSmall
                }

                Image {
                    id: moreImage
                    anchors {
                        right: parent.right
                        rightMargin: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    source: "image://theme/icon-m-right?" + Theme.highlightColor
                    transformOrigin: Item.Center
                    rotation: open ? 90 : 0
                    Behavior on rotation { NumberAnimation { duration: 100 } }
                }

                Rectangle {
                    anchors.fill: parent
                    z: -1 // behind everything
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            Spacer { height: Theme.paddingMedium }
        }
    }

    ViewPlaceholder {
        enabled: view.count == 0 && startupComplete
        text: qsTr("No entries yet")
        hintText: qsTr("Pull down to add entries")
    }
}
