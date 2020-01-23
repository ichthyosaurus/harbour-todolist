import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../js/storage.js" as Storage
import "../components"
import "../constants" 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    function addItemFor(date) {
        var dialog = pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), { date: date })
        dialog.accepted.connect(function() {
            addItem(date, dialog.text.trim(), dialog.description.trim());
        });
    }

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: rawModel

        sorters: [
            RoleSorter { roleName: "date"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "weight"; sortOrder: Qt.DescendingOrder }
        ]

        proxyRoles: [
            ExpressionRole {
                name: "_isYoung"
                expression: model.date >= today
            }
        ]

        filters: ValueFilter {
            roleName: "_isYoung"
            value: true
        }
    }

    TodoList {
        id: todoList
        anchors.fill: parent
        model: filteredModel

        header: PageHeader {
            title: qsTr("Todo List")
            description: currentCategoryName
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Change category")
                onClicked: pageStack.push(Qt.resolvedUrl("CategoriesPage.qml"))
            }
            MenuItem {
                text: qsTr("Add entry for tomorrow")
                onClicked: page.addItemFor(tomorrow)
            }
            MenuItem {
                text: qsTr("Add entry for today")
                onClicked: page.addItemFor(today)
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Show old entries")
                onClicked: pageStack.push(Qt.resolvedUrl("ArchivePage.qml"));
            }
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        footer: Spacer { }
    }
}
