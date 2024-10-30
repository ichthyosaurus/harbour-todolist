/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.Tabs 1.0
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    TabView {
        anchors.fill: parent
        currentIndex: 1
        tabBarPosition: Qt.AlignBottom
        tabBarVisible: !main.hideTabBar
        cacheSize: 10

        Tab {
            title: qsTr("Recurrings")
            // icon: "image://theme/icon-m-repeat"
            Component { RecurringsView {} }
        }

        Tab {
            title: qsTr("To-do List")
            // icon: "image://theme/icon-m-acknowledge"
            Component { TodoListView {} }
        }

        Tab {
            title: qsTr("Projects")
            // icon: "image://theme/icon-m-company"
            Component { ProjectsView {} }
        }
    }
}
