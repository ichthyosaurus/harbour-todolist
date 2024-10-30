import QtQuick 2.0
import Opal.DragDrop 1.0

ViewDragHandler {
    id: viewDragHandler
    handleMove: false

    onItemDropped: {
        listView.model.moveItem(currentIndex, finalIndex, true)
    }

    onItemMoved: {
        listView.model.moveItem(fromIndex, toIndex, false)
    }
}
