import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../constants" 1.0

SilicaListView {
    id: view
    model: filteredModel
    VerticalScrollDecorator { flickable: view }
    property int showFakeNavigation: FakeNavigation.None

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: recurringsModel

        sorters: [
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "intervalDays"; sortOrder: Qt.DescendingOrder },
            RoleSorter { roleName: "startDate"; sortOrder: Qt.AscendingOrder }
        ]
    }

    header: FakeNavigationHeader {
        title: qsTr("Recurring Entries")
        showNavigation: showFakeNavigation
    }

    PullDownMenu {
        MenuItem {
            text: qsTr("Add recurring entry")
            onClicked: {
                //                    var dialog = pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), { date: new Date(NaN), descriptionEnabled: false })
                //                    dialog.accepted.connect(function() {
                //                        main.addProject(dialog.text.trim());
                //                    });
                console.log("add recurring...")
            }
        }
    }

    footer: Spacer { }

    delegate: TodoListBaseItem {
        editable: false
        descriptionEnabled: true
        infoMarkerEnabled: false
        title: model.text
        description: model.description
    }

    ViewPlaceholder {
        enabled: view.count == 0 && startupComplete
        text: qsTr("No entries yet")
        hintText: qsTr("This page will show a list of all recurring entries.")
    }
}
