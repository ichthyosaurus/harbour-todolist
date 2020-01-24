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
        sourceModel: rawModel

        sorters: [
            RoleSorter { roleName: "date"; sortOrder: Qt.DescendingOrder },
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "weight"; sortOrder: Qt.DescendingOrder }
        ]

        proxyRoles: [
            ExpressionRole {
                name: "_isOld"
                expression: model.date < today
            }
        ]

        filters: ValueFilter {
            roleName: "_isOld"
            value: true
        }
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: filteredModel
        height: contentHeight + Theme.paddingLarge
        VerticalScrollDecorator { flickable: view }

        header: PageHeader {
            title: qsTr("Archived Entries")
            description: currentCategoryName
        }

        footer: Spacer { }

        delegate: TodoListItem {
            editable: false
            onCopyAndMarkItem: {
                var sourceIndex = view.model.mapToSource(which);
                main.updateItem(sourceIndex, mainState, subState);
                main.copyItemTo(sourceIndex, copyToDate);
            }
        }

        section {
            property: 'date'
            delegate: SectionHeader {
                text: new Date(section).toLocaleString(Qt.locale(), main.fullDateFormat)
                height: Theme.itemSizeExtraSmall
            }
        }

        ViewPlaceholder {
            enabled: view.count == 0 && startupComplete
            text: qsTr("No entries yet")
            hintText: qsTr("This page will show a list of all old entries.")
        }
    }
}
