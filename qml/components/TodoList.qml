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
import SortFilterProxyModel 0.2
import "../constants" 1.0
import "../js/helpers.js" as Helpers

SilicaListView {
    id: view
    VerticalScrollDecorator { flickable: view }

    readonly property var defaultClosedSections: [somedayString]
    property var closedSections: defaultClosedSections

    Connections {
        target: main.configuration
        onValueChanged: if (key === "currentProject") closedSections = defaultClosedSections
    }

    delegate: TodoListItem {
        onMarkItemAs: updateItem(view.model.mapToSource(which), mainState, subState);
        onCopyAndMarkItem: {
            var sourceIndex = view.model.mapToSource(which);
            updateItem(sourceIndex, mainState, subState);
            main.copyItemTo(sourceIndex, copyToDate);
        }
        onSaveItemTexts: updateItem(view.model.mapToSource(which), undefined, undefined, newText, newDescription);
        onDeleteThisItem: deleteItem(view.model.mapToSource(which))
        hidden: closedSections.indexOf(Helpers.getDateString(date)) !== -1
    }

    section {
        property: 'date'
        delegate: Column {
            width: parent.width
            property string sectionString: String(section).split("T")[0]
            property bool isToday: sectionString === todayString
            property bool isTomorrow: sectionString === tomorrowString
            property bool isSomeday: sectionString === somedayString
            property bool open: !isSomeday

            Connections {
                target: main.configuration
                onValueChanged: if (key === "currentProject") open = !isSomeday;
            }

            Spacer { height: Theme.paddingLarge }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall

                onClicked: {
                    open = !open;
                    var tmp = closedSections;
                    if (!open) {
                        tmp.push(sectionString);
                    } else {
                        tmp = tmp.filter(function(e) { return e !== sectionString; });
                    }
                    closedSections = tmp;
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
                    text: isSomeday ? "" : new Date(section).toLocaleString(
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
