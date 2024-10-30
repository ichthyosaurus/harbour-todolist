import QtQuick 2.0
import Sailfish.Silica 1.0
import Todolist.Constants 1.0
import "../js/storage.js" as Storage

ListModel {
    property var _dateCounts: ({})

    function reset() {
        clear()
        _dateCounts = {}
    }

    function addItem(item, _, commit) {
        // This *only* saves the new position to the database
        // if "commit" is true!
        // The item *must* already be saved to the database
        // before calling thing function!

        if (!_dateCounts.hasOwnProperty(item.dateString)) {
            _dateCounts[item.dateString] = 0
        }

        var newIndex = count

        for (var i = 0; i < count; ) {
            var compare = get(i)

            if (compare.date > item.date) {
                newIndex = i
                break
            }

            i += _dateCounts[compare.dateString]

            if (compare.dateString === item.dateString) {
                newIndex = i
                break
            }
        }

        _dateCounts[item.dateString] += 1
        insert(newIndex, item)

        if (!!commit) {
            // save the new position
            moveItem(newIndex, newIndex, true)

            // make sure it is placed in the correct category
            updateState(newIndex, item.entryState)
        }
    }

    function removeItem(index) {
        // This does *not* save to the database!
        var item = get(index)
        var dateString = item.dateString
        remove(index)

        if (_dateCounts.hasOwnProperty(dateString)) {
            _dateCounts[dateString] -= 1
        } else {
            _dateCounts[dateString] = 0
        }
    }

    function moveItem(fromIndex, toIndex, commit) {
        // This *only* saves to the database if "commit" is true!
        // This *changes* the item's index so the index passed
        // into this function will no longer point to the item!

        var item = get(fromIndex)
        var targetItem = get(count-1)

        if (toIndex < 0) {
            // FIXME Opal.DragDrop doesn't notify when an item is dropped out of bounds
            console.log("beyond the top, not moving", fromIndex, "->", toIndex)

            if (commit) {
                // save current position
                toIndex = fromIndex
                targetItem = get(fromIndex)
            } else {
                return
            }
        } else if (toIndex < count) {
            targetItem = get(toIndex)
        }

        if (item.dateString !== targetItem.dateString) {
            console.log("date mismatch, not moving", fromIndex, "->", toIndex)

            if (commit) {
                // save current position
                toIndex = fromIndex
            } else {
                return
            }
        }

        if (item.entryState !== targetItem.entryState) {
            console.log("state mismatch, not moving", fromIndex, "->", toIndex)

            if (commit) {
                // save current position
                toIndex = fromIndex
            } else {
                return
            }
        }

        move(fromIndex, toIndex, 1)

        if (!!commit) {
            _refreshWeights(toIndex)
            console.log("saved move of task item", item.entryId,
                        "from", fromIndex, "to", toIndex)
        } else {
            console.log("moved task item", item.entryId,
                        "from", fromIndex, "to", toIndex)
        }
    }

    function updateState(index, newState, _) {
        // This *saves* the new position to the database!
        // This *changes* the item's index so the index passed
        // into this function will no longer point to the item!

        var item = get(index)
        var newIndex = count

        for (var i = 0; i < count; ) {
            var compare = get(i)

            if (compare.date > item.date) {
                newIndex = i
                break
            }

            if (compare.dateString === item.dateString) {
                for (var x = i; x < i+_dateCounts[compare.dateString]; ++x) {
                    newIndex = x

                    if (get(x).entryState > newState) {
                        newIndex = newIndex - (item.entryState < newState ? 1 : 0)
                        break
                    }
                }

                break
            } else {
                i += _dateCounts[compare.dateString]
            }
        }

        setProperty(index, 'entryState', newState)
        move(index, newIndex, 1)
        _refreshWeights(newIndex)
    }

    function _refreshWeights(forIndex) {
        // recalculate weights
        // this is horrible, inefficient, and ugly,
        // but it works for now

        var item = get(forIndex)

        for (var i = count-1; i >= 0; ) {
            var compare = get(i)

            if (compare.dateString === item.dateString) {
                if (compare.entryState === item.entryState) {
                    var weight = 0

                    for (var x = i; x >= 0; --x) {
                        var updateEntry = get(x)

                        if (updateEntry.entryState !== item.entryState) {
                            break
                        }

                        var rowid = updateEntry.entryId
                        console.log("[entries model] setting entry weight for", rowid, x,
                                    "from", updateEntry.weight, "to", weight)
                        setProperty(x, 'weight', weight)
                        Storage.saveEntryWeight(rowid, weight)
                        ++weight
                    }

                    break
                } else {
                    i -= 1
                }
            } else {
                i -= _dateCounts[compare.dateString]
            }
        }
    }
}
