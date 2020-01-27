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
import "../constants" 1.0

PageHeader {
    clip: true

    property int showNavigation: FakeNavigation.None
    property bool _showLeftNavigation: showNavigation === FakeNavigation.Left || showNavigation === FakeNavigation.Both
    property bool _showRightNavigation: showNavigation === FakeNavigation.Right || showNavigation === FakeNavigation.Both

    GlassItem {
        id: indicatorLeft
        visible: _showLeftNavigation

        anchors {
            left: parent.left
            leftMargin: -(width/2)
            verticalCenter: _titleItem.verticalCenter
        }

        color: mouseLeft.pressed ? Theme.highlightColor : Theme.lightPrimaryColor
        backgroundColor: Theme.backgroundGlowColor
        radius: 0.22
        falloffRadius: 0.18

        MouseArea {
            id: mouseLeft
            enabled: _showLeftNavigation
            anchors.fill: parent
            onClicked: main.fakeNavigateLeft()
        }
    }

    GlassItem {
        id: indicatorRight
        visible: _showRightNavigation

        anchors {
            right: parent.right
            rightMargin: -(width/2)
            verticalCenter: _titleItem.verticalCenter
        }

        color: mouseRight.pressed ? Theme.highlightColor : Theme.lightPrimaryColor
        backgroundColor: Theme.backgroundGlowColor
        radius: 0.22
        falloffRadius: 0.18

        MouseArea {
            id: mouseRight
            enabled: _showRightNavigation
            anchors.fill: parent
            onClicked: main.fakeNavigateRight()
        }
    }
}
