import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../js/storage.js" as Storage
import "../components"
import "../config" 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    signal showAddItemGuiFor(var date, var forWhen)

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: rawModel

        sorters: [
            RoleSorter { roleName: "date"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "entrystate"; sortOrder: Qt.AscendingOrder },
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

        header: Item {
            width: parent.width
            height: head.height + (addItemGui.visible ? addItemGui.height : 0)

            PageHeader {
                id: head
                title: qsTr("Todo List")
            }

            Column {
                id: addItemGui
                visible: false
                width: parent.width
                anchors.top: head.bottom
                property var saveDate

                onVisibleChanged: {
                    if (!visible) {
                        saveDate = undefined;
                        subtitleLabel.text = "";
                        taskText.text = "";
                        descriptionText.text = "";
                    }
                }

                Component.onCompleted: showAddItemGuiFor.connect(function(date, forWhen) {
                    visible = true;
                    saveDate = date;
                    taskText.forceActiveFocus();

                    if (forWhen == EntrySubState.today) {
                        subtitleLabel.text = qsTr("for today");
                    } else if (forWhen == EntrySubState.tomorrow) {
                        subtitleLabel.text = qsTr("for tomorrow");
                    } else {
                        subtitleLabel.text = qsTr("for later");
                    }
                })

                Item {
                    width: parent.width
                    height: Theme.itemSizeSmall

                    Label {
                        id: titleLabel
                        anchors {
                            left: parent.left; leftMargin: Theme.horizontalPageMargin
                            right: subtitleLabel.left; rightMargin: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter
                        }
                        text: qsTr("Add new entry")
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    Label {
                        id: subtitleLabel
                        anchors {
                            right: parent.right; rightMargin: Theme.paddingLarge
                            verticalCenter: parent.verticalCenter
                        }
                        color: Theme.highlightColor
                        opacity: Theme.opacityHigh
                        font.pixelSize: Theme.fontSizeSmall
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

                TextField {
                    id: taskText
                    width: parent.width
                    focus: true
                    placeholderText: qsTr("Enter task text")
                    label: qsTr("Task text")
                    // inputMethodHints: Qt.ImhNoPredictiveText
                }

                TextArea {
                    id: descriptionText
                    width: parent.width
                    placeholderText: qsTr("Enter optional description")
                    label: qsTr("Description")
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingLarge

                    Button {
                        text: qsTr("Save")
                        onClicked: {
                            if (!addItemGui.saveDate || !taskText.text) {
                                return;
                            }

                            addItem(addItemGui.saveDate, taskText.text, descriptionText.text);
                            addItemGui.visible = false;
                        }
                    }

                    Button {
                        text: qsTr("Abort")
                        onClicked: {
                            addItemGui.visible = false;
                        }
                    }
                }

                Spacer { }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Add entry for tomorrow")
                onClicked: showAddItemGuiFor(tomorrow, EntrySubState.tomorrow)
            }
            MenuItem {
                text: qsTr("Add entry for today")
                onClicked: showAddItemGuiFor(today, EntrySubState.today)
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Show old entries")
                onClicked: pageStack.push(Qt.resolvedUrl("ArchivePage.qml"));
            }
        }

        footer: Spacer { }
    }
}
