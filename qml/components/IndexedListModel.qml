import QtQuick 2.0
import Todolist.Constants 1.0
import "../js/storage.js" as Storage

ListModel {
    id: root

    property string type  // required
    property bool withSubState // required
    property string rowidProperty: "entryId"  // required

    function reset() {
        clear()
        todayPositions.reset()
        tomorrowPositions.reset()
        thisWeekPositions.reset()
        somedayPositions.reset()
    }

    function addItem(dict, sortHint, commit) {
        // This *only* saves the new position to the database.
        // The item *must* already be saved to the database
        // before caling thing function!
        //
        // Pass a function(newItem, existingItem) as sortHint
        // to influence where the new item will be inserted.
        // Return true if the position is ok.
        // If the function never returns true, the item will
        // be added at the end of the section.

        var positions = getPositions(dict)
        var minIndex = 0
        var newIndex = 0

        if (dict.entryState === EntryState.Todo) {
            minIndex = positions.firstTodoIndex
            newIndex = positions.firstTodoIndex + positions.todoCount
            ++positions.todoCount
        } else if (dict.entryState === EntryState.Ignored) {
            minIndex = positions.firstIgnoredIndex
            newIndex = positions.firstIgnoredIndex + positions.ignoredCount
            ++positions.ignoredCount
        } else if (dict.entryState === EntryState.Done) {
            minIndex = positions.firstDoneIndex
            newIndex = positions.firstDoneIndex + positions.doneCount
            ++positions.doneCount
        } else {
            console.error("cannot add item with unknown entry state",
                          dict.entryState, "to", type)
        }

        if (sortHint instanceof Function && newIndex > 0) {
            for (var i = newIndex-1; i >= minIndex; --i) {
                if (sortHint(dict, root.get(i))) {
                    newIndex = i+1
                    break
                }
            }
        }

        console.log("[model]", type, newIndex, JSON.stringify(dict))
        root.insert(newIndex, dict)

        if (!!commit) {
            // save the new position
            moveItem(newIndex, newIndex, true)
        }
    }

    function removeItem(index) {
        // This does *not* save to the database!

        var item = root.get(index)
        var positions = getPositions(item)

        if (item.entryState === EntryState.Todo) {
            --positions.todoCount
        } else if (item.entryState === EntryState.Ignored) {
            --positions.ignoredCount
        } else if (item.entryState === EntryState.Done) {
            --positions.doneCount
        } else {
            console.error("cannot remove item with unknown entry state",
                          item.entryState, "from", type)
        }

        console.log("[model] removing item", index,
                    "id", item[rowidProperty], "from", type)

        root.remove(index, 1)
    }

    function moveItem(fromIndex, toIndex, commit) {
        // This *only* saves to the database if "commit" is true!
        // This *changes* the item's index so the index passed
        // into this function will no longer point to the item!

        var item = root.get(fromIndex)
        var positions = getPositions(item)
        var state = item.entryState

        var minIndex = -1
        var maxIndex = -1

        if (state === EntryState.Todo) {
            minIndex = positions.firstTodoIndex
            maxIndex = positions.firstIgnoredIndex - 1
        } else if (state === EntryState.Ignored) {
            minIndex = positions.firstIgnoredIndex
            maxIndex = positions.firstDoneIndex - 1
        } else if (state === EntryState.Done) {
            minIndex = positions.firstDoneIndex
            maxIndex = positions.lastIndex
        }

        if (toIndex < minIndex) {
            toIndex = minIndex
        } else if (toIndex > maxIndex) {
            toIndex = maxIndex
        }

        root.move(fromIndex, toIndex, 1)

        if (!!commit) {
            Storage.moveItem(type, item[rowidProperty], toIndex)
            console.log("saved move of", type, "item", item[rowidProperty],
                        "from", fromIndex, "to", toIndex)
        } else {
            console.log("moved", type, "item", item[rowidProperty],
                        "from", fromIndex, "to", toIndex)
        }
    }

    function updateState(index, newState, sortHint) {
        // This *saves* to the database!
        // This *changes* the item's index so the index passed
        // into this function will no longer point to the item!
        //
        // Pass a function(newItem, existingItem) as sortHint
        // to influence where the new item will be inserted.
        // Return true if the position is ok.
        // If the function never returns true, the item will
        // be added at the end of the section.

        var item = root.get(index)
        var positions = getPositions(item)
        positions.updateState(index, newState, sortHint)
    }

    function getPositions(item) {
        if (withSubState) {
            return positions[item.subState]
        } else {
            return positions[0]
        }
    }

    // ----- internal -----

    readonly property var positions: ({})
    readonly property ListIndices todayPositions: ListIndices {
        model: root
        type: root.type
        rowidProperty: root.rowidProperty
        firstTodoIndex: 0
    }
    readonly property ListIndices tomorrowPositions: ListIndices {
        model: root
        type: root.type
        rowidProperty: root.rowidProperty
        firstTodoIndex: todayPositions.lastIndex + 1
    }
    readonly property ListIndices thisWeekPositions: ListIndices {
        model: root
        type: root.type
        rowidProperty: root.rowidProperty
        firstTodoIndex: tomorrowPositions.lastIndex + 1
    }
    readonly property ListIndices somedayPositions: ListIndices {
        model: root
        type: root.type
        rowidProperty: root.rowidProperty
        firstTodoIndex: thisWeekPositions.lastIndex + 1
    }

    Component.onCompleted: {
        if (withSubState) {
            positions[EntrySubState.Today] = todayPositions
            positions[EntrySubState.Tomorrow] = tomorrowPositions
            positions[EntrySubState.ThisWeek] = thisWeekPositions
            positions[EntrySubState.Someday] = somedayPositions
        } else {
            positions[0] = todayPositions
        }
    }
}
