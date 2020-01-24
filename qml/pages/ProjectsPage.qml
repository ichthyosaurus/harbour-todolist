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
        sourceModel: projectsModel
        sorters: [
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "entryId"; sortOrder: Qt.AscendingOrder }
        ]
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: filteredModel
        VerticalScrollDecorator { flickable: view }

        header: PageHeader {
            title: qsTr("Projects")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add project")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), { date: new Date(NaN), descriptionEnabled: false })
                    dialog.accepted.connect(function() {
                        main.addProject(dialog.text.trim());
                    });
                }
            }
        }

        footer: Spacer { }

        delegate: TodoListBaseItem {
            id: item
            editable: true
            deletable: entryId !== 0
            descriptionEnabled: false
            infoMarkerEnabled: false
            title: model.name
            highlighted: main.configuration.currentProject === entryId

            onMarkItemAs: main.updateProject(view.model.mapToSource(which), undefined, mainState);
            onSaveItemTexts: main.updateProject(view.model.mapToSource(which), newText, undefined);
            onDeleteThisItem: main.deleteProject(view.model.mapToSource(which))
            extraDeleteWarning: qsTr("All entries belonging to this project will be deleted!")

            customClickHandlingEnabled: true
            showMenuOnPressAndHold: true
            onClicked: {
                if (main.configuration.currentProject !== entryId) {
                    main.setCurrentProject(entryId);
                }
            }

            menu: Component {
                ContextMenu {
                    MenuItem {
                        visible: entryState !== EntryState.todo
                        text: qsTr("mark as active")
                        onClicked: markItemAs(index, EntryState.todo, undefined)
                    }
                    MenuItem {
                        visible: entryState !== EntryState.ignored
                        text: qsTr("mark as halted")
                        onClicked: markItemAs(index, EntryState.ignored, undefined)
                    }
                    MenuItem {
                        visible: entryState !== EntryState.done
                        text: qsTr("mark as finished")
                        onClicked: markItemAs(index, EntryState.done, undefined)
                    }
                    MenuItem {
                        visible: editable
                        text: deletable ? qsTr("edit or delete") : qsTr("edit")
                        onClicked: startEditing()
                    }
                }
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
