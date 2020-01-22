import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../config" 1.0

GroupedDrawer {
    id: drawer
    property date date: new Date()
    title: "(error)"
    subtitle: date.toLocaleString(Qt.locale(), main.fullDateFormat)
    clip: false

    ListModel {
        id: rawEntriesModel
    }

    SortFilterProxyModel {
        id: entriesModel
        sourceModel: rawEntriesModel

        sorters: [
            RoleSorter { roleName: "date"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "entrystate"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "weight"; sortOrder: Qt.DescendingOrder }
        ]
        filters: ValueFilter {
            roleName: "date"
            value: date
        }
    }

    open: false
    contents: Component {
        SilicaListView {
            id: view
            width: parent.width; height: contentHeight > 0 ? contentHeight : placeholder.height
            model: entriesModel

            header: Column {
                id: listHeader
                width: parent.width
                height: childrenRect.height

                SectionHeader {
                    text: qsTr("Add new entry")
                }

                TextField {
                    id: taskText
                    width: parent.width
                    focus: true
                    placeholderText: qsTr("Enter task text")
                    label: qsTr("Task text")
                }

                TextArea {
                    width: parent.width
                    placeholderText: qsTr("Enter optional description")
                    label: qsTr("Description")
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingLarge

                    Button {
                        text: qsTr("Save")
                        onClicked: console.log("new entry: save", date)
                    }

                    Button {
                        text: qsTr("Abort")
                        onClicked: console.log("new entry: abort", date)
                    }
                }

                Spacer { }
            }

            delegate: EntriesListDelegate { }

            section {
                property: 'entrystate'
                delegate: Item {
                    visible: section != EntryState.todo
                    width: parent.width
                    height: visible ? Theme.paddingLarge : 0

                    /*Separator {
                        // somehow, this isn't hidden when parent.visible=false
                        visible: section != EntryState.todo
                        x: Theme.horizontalPageMargin-Theme.paddingMedium
                        width: parent.width-2*x
                        horizontalAlignment: Qt.AlignLeft
                        color: Theme.secondaryColor
                        anchors.verticalCenter: parent.verticalCenter
                    }*/
                }
            }

            EntriesListPlaceholder {
                id: placeholder
                date: drawer.date
            }
        }
    }

    Component.onCompleted: {
        rawEntriesModel.append({date: tomorrow, entrystate: EntryState.done, substate: EntrySubState.today, parentItem: "",
                           weight: 1, text: "Schon erledigt", description: ""});
        rawEntriesModel.append({date: tomorrow, entrystate: EntryState.todo, substate: EntrySubState.today, parentItem: "",
                           weight: 1, text: "Kochen", description: ""});
        rawEntriesModel.append({date: today, entrystate: EntryState.todo, substate: EntrySubState.today, parentItem: "",
                           weight: 1, text: "Etwas Kompliziertes machen", description: "Das muss hier noch ausführlich beschrieben werden!"});
        rawEntriesModel.append({date: today, entrystate: EntryState.ignored, substate: EntrySubState.today, parentItem: "",
                           weight: 1, text: "Nö, das mach' ich nicht", description: ""});
        rawEntriesModel.append({date: today, entrystate: EntryState.todo, substate: EntrySubState.tomorrow, parentItem: "",
                           weight: 1, text: "Wäsche waschen", description: ""});
        rawEntriesModel.append({date: today, entrystate: EntryState.done, substate: EntrySubState.tomorrow, parentItem: "",
                           weight: 1, text: "Nichts mehr zu tun", description: ""});
    }
}
