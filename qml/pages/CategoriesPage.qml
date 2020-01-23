import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../config" 1.0

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

        footer: Spacer { }

        delegate: TodoListBaseItem {
            editable: true
            descriptionEnabled: false
            infoMarkerEnabled: false
            title: model.name
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
