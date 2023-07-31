/*
 * This page limits the scope of tasks to that of a given project, making it quicker to work on a project.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../constants" 1.0

Page {

    id: projectPage
    property int projectId

    TodoListView {
        id: todoListView
        width: parent.width;
        height: parent.height
        showFakeNavigation: FakeNavigation.Both
        projectId: projectId
    }

    Component.onCompleted: {
        todoListView.projectId = projectId
    }

}
