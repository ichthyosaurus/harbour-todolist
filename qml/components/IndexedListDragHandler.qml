/*
 * This file is part of harbour-todolist.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 */

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
