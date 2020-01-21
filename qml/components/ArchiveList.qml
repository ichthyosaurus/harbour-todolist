import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config" 1.0

SilicaListView {
    id: view
    width: parent.width; height: childrenRect.height

    delegate: EntriesListDelegate {
        editable: false
    }

    section {
        property: 'date'
        delegate: SectionHeader {
            text: section
            height: Theme.itemSizeExtraSmall
        }
    }

    EntriesListPlaceholder { date: date }
}
