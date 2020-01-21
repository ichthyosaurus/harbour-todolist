import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../config" 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

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
        proxyRoles: [
            ExpressionRole {
                name: "isOld"
                expression: model.date < today
            }
        ]

        filters: ValueFilter {
            roleName: "isOld"
            value: true
        }
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: entriesModel

        header: PageHeader {
            title: qsTr("Archived Entries")
        }

        delegate: EntriesListDelegate {
            editable: false
        }

        section {
            property: 'date'
            delegate: SectionHeader {
                text: new Date(section).toLocaleString(Qt.locale(), main.fullDateFormat)
                height: Theme.itemSizeExtraSmall
            }
        }

        EntriesListPlaceholder { date: date }
    }

    Component.onCompleted: {
        rawEntriesModel.append({date: new Date("1970-01-01T00:00Z"), entrystate: EntryState.done, substate: EntrySubState.today, parentItem: "",
                           weight: 1, text: "Schon erledigt", description: ""});
        rawEntriesModel.append({date: new Date("1970-01-04T00:00Z"), entrystate: EntryState.todo, substate: EntrySubState.today, parentItem: "",
                           weight: 1, text: "Kochen", description: ""});
        rawEntriesModel.append({date: new Date("1970-01-01T00:00Z"), entrystate: EntryState.todo, substate: EntrySubState.today, parentItem: "",
                           weight: 1, text: "Etwas Kompliziertes machen", description: "Das muss hier noch ausführlich beschrieben werden!"});
        rawEntriesModel.append({date: new Date("1970-01-02T00:00Z"), entrystate: EntryState.ignored, substate: EntrySubState.today, parentItem: "",
                           weight: 1, text: "Nö, das mach' ich nicht", description: ""});
        rawEntriesModel.append({date: new Date("1970-02-01T00:00Z"), entrystate: EntryState.todo, substate: EntrySubState.tomorrow, parentItem: "",
                           weight: 1, text: "Wäsche waschen", description: ""});
        rawEntriesModel.append({date: new Date("1970-01-01T00:00Z"), entrystate: EntryState.done, substate: EntrySubState.tomorrow, parentItem: "",
                           weight: 1, text: "Nichts mehr zu tun", description: ""});
    }
}
