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
import "../components"
import "../constants" 1.0

CoverBackground {
    SortFilterProxyModel {
        id: filteredModel
        sourceModel: status === Cover.Active ? rawModel : null

        sorters: [
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "weight"; sortOrder: Qt.DescendingOrder }
        ]

        filters: [
            AllOf {
                ValueFilter {
                    roleName: "date"
                    value: today
                }
                ValueFilter {
                    roleName: "subState"
                    value: EntrySubState.today
                }
            },
            AnyOf {
                ValueFilter {
                    roleName: "entryState"
                    value: EntryState.todo
                }
                ValueFilter {
                    roleName: "entryState"
                    value: EntryState.ignored
                }
            }
        ]
    }

    SilicaListView {
        id: view
        clip: true

        anchors {
            top: parent.top; topMargin: Theme.paddingMedium
            left: parent.left; leftMargin: Theme.paddingMedium
            right: parent.right; rightMargin: Theme.paddingMedium
            bottom: coverActionArea.top; bottomMargin: Theme.paddingMedium
        }

        VerticalScrollDecorator { id: scrollBar; flickable: view }

        model: filteredModel
        delegate: ListItem {
            id: item
            anchors.topMargin:  Theme.paddingSmall
            height: entryLabel.height + Theme.paddingSmall
            opacity: 1.0 - ((item.y - view.contentY)/view.height * 0.5)

            HighlightImage {
                id: statusIcon
                width: 0.8*Theme.iconSizeExtraSmall
                height: width
                anchors { top: parent.top; topMargin: Theme.paddingSmall }
                color: Theme.primaryColor
                source: {
                    if (entryState === EntryState.todo) "../images/icon-todo-small.png"
                    else if (entryState === EntryState.ignored) "../images/icon-ignored-small.png"
                    else if (entryState === EntryState.done) "../images/icon-done-small.png"
                }
            }

            Label {
                id: entryLabel
                maximumLineCount: 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: model.text
                truncationMode: TruncationMode.Fade
                anchors { leftMargin: Theme.paddingSmall; left: statusIcon.right; right: parent.right }
            }
        }

        Column {
            id: placeholderColumn
            visible: view.count === 0

            anchors {
                left: parent.left; right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: Theme.paddingSmall

            Label {
                width: parent.width; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere; font.pixelSize: Theme.fontSizeLarge
                text: qsTr("Todo List")
                color: Theme.highlightColor
                opacity: 1.0
            }

            Label {
                width: parent.width; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap; font.pixelSize: Theme.fontSizeMedium
                opacity: Theme.opacityHigh
                text: currentProjectName
                color: Theme.highlightColor
                maximumLineCount: 5
                truncationMode: TruncationMode.Fade
                elide: Text.ElideRight
            }
        }
    }

    property int currentPageNumber: 1
    property int scrollPerPage: 2

    function showNextPage() { showPage(1); }
    function showPrevPage() { showPage(-1); }
    function showPage(pageOffset) {
        anim.running = false;
        var pos = view.contentY;
        var destPos;

        view.positionViewAtIndex((currentPageNumber+pageOffset)*scrollPerPage-scrollPerPage, ListView.Beginning);
        destPos = view.contentY;
        scrollBar.showDecorator();

        currentPageNumber = currentPageNumber + pageOffset;
        if (pos === destPos && pageOffset < 0) {
            // if the page number was too high, we skip a page
            // until something moves
            showPrevPage();
        }

        anim.from = pos;
        anim.to = destPos;
        anim.running = true;
    }

    NumberAnimation { id: anim; target: view; property: "contentY"; duration: 300 }

    CoverActionList {
        id: coverActionList

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                if (currentPageNumber > 1) showPrevPage()
                else scrollBar.showDecorator();
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                var dialog = pageStack.push(Qt.resolvedUrl("../pages/AddItemDialog.qml"), { date: main.today },
                                            PageStackAction.Immediate)
                dialog.accepted.connect(function() {
                    addItem(dialog.date, dialog.text.trim(), dialog.description.trim());
                });
                main.activate();
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                if (currentPageNumber < (view.count/scrollPerPage)) showNextPage();
                else scrollBar.showDecorator();
            }
        }
    }

    onStatusChanged: {
        // Trigger the update check of the date values once the application is resumed.
        refreshDates();
    }
}
