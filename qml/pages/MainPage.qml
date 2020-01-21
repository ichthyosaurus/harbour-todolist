import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Add entry for tomorrow")
                onClicked: console.log("add for tomorrow")
            }
            MenuItem {
                text: qsTr("Add entry for today")
                onClicked: console.log("add for today")
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Show old entries")
                onClicked: pageStack.push(Qt.resolvedUrl("ArchivePage.qml"));
            }
        }

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Todo List")
            }

            TodoDrawer {
                date: getDate(1)
                title: qsTr("Tomorrow")
                open: false
            }

            TodoDrawer {
                date: today
                title: qsTr("Today")
                open: true
            }
        }
    }

    function getDate(offset) {
        var currentDate = new Date();
        currentDate.setDate(currentDate.getDate() + offset);
        return currentDate;
    }
}
