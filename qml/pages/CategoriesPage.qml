import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../constants" 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: categoriesModel
        sorters: [
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "entryId"; sortOrder: Qt.AscendingOrder }
        ]
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: filteredModel

        header: PageHeader {
            title: qsTr("Categories")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add category")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), { date: new Date(NaN), descriptionEnabled: false })
                    dialog.accepted.connect(function() {
                        main.addCategory(dialog.text.trim());
                    });
                }
            }
        }

        footer: Spacer { }

        delegate: TodoListBaseItem {
            id: item
            editable: true
            descriptionEnabled: false
            infoMarkerEnabled: false
            title: model.name
            property bool isCurrentCategory: main.configuration.currentCategory === entryId

            onMarkItemAs: main.updateCategory(view.model.mapToSource(which), undefined, mainState);
            onSaveItemTexts: main.updateCategory(view.model.mapToSource(which), newText, undefined);
            onDeleteThisItem: main.deleteItem(view.model.mapToSource(which))

            menu: Component {
                ContextMenu {
                    MenuItem {
                        visible: !isCurrentCategory
                        text: qsTr("select")
                        onClicked: main.setCurrentCategory(entryId)
                    }
                    MenuItem {
                        visible: entryState !== EntryState.todo
                        text: qsTr("activate")
                        onClicked: markItemAs(index, EntryState.todo, undefined)
                    }
                    MenuItem {
                        visible: entryState !== EntryState.ignored
                        text: qsTr("halt")
                        onClicked: markItemAs(index, EntryState.ignored, undefined)
                    }
                    MenuItem {
                        visible: entryState !== EntryState.done
                        text: qsTr("finish")
                        onClicked: markItemAs(index, EntryState.done, undefined)
                    }
                }
            }

            function select() {
                if (isCurrentCategory) highlighted = true;
                else highlighted = undefined;
            }

            Component.onCompleted: {
                select();
                main.configuration.valueChanged.connect(function(key) {
                    if (key === "currentCategory") item.select();
                })
            }
        }

        section {
            property: 'entryState'
            delegate: Spacer { }
        }

        ViewPlaceholder {
            enabled: view.count == 0
            text: qsTr("No entries")
            hintText: qsTr("This should not be possible. Most probably a database error occurred.")
        }
    }
}
