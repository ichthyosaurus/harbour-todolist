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

Page {
    id: page
    allowedOrientations: Orientation.All

    VisualItemModel {
        id: viewsModel
        TodoListView { // middle, index 0, offset 0 (or 3, when coming from 2)
            width: parent.width; height: parent.height
            showFakeNavigation: FakeNavigation.Both
        }

        ProjectsView { // right, index 1, offset 2
            width: parent.width; height: parent.height
            showFakeNavigation: FakeNavigation.Left
        }

        RecurringsView { // left, index 2, offset 1
            width: parent.width; height: parent.height
            showFakeNavigation: FakeNavigation.Right
        }
    }

    SlideshowView {
        id: views
        anchors.fill: parent
        clip: true
        itemWidth: width
        interactive: true
        currentIndex: 0
        model: viewsModel

        onOffsetChanged: {
            if (currentIndex === 0) return;
            else if (currentIndex === 1 && offset < 2) offset = 2;
            else if (currentIndex === 2 && offset > 1) offset = 1;
        }
    }

    NumberAnimation { id: anim; target: views; property: "offset"; duration: 300 }

    Connections {
        target: main

        function animateNavigation(from, to) {
            anim.running = false;
            anim.from = from; anim.to = to;
            anim.running = true;
        }

        onFakeNavigateLeft: {
            if (views.currentIndex === 0) animateNavigation(0, 1)
            else if (views.currentIndex === 1) animateNavigation(2, 3)
        }

        onFakeNavigateRight: {
            if (views.currentIndex === 0) animateNavigation(3, 2)
            else if (views.currentIndex === 2) animateNavigation(1, 0)
        }
    }
}
