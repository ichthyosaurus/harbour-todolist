import QtQuick 2.0
import Todolist.Constants 1.0
import "../js/storage.js" as Storage
import "../js/helpers.js" as Helpers

ListModel {
    id: root

    property string type  // required
    property bool withSubState // required
    property string rowidProperty: "entryId"  // required

    function reset() {
        clear()
        _initPositions()
    }

    function addItem(dict, sortHint, commit) {
        // This *only* saves the new position to the database
        // if "commit" is true!
        // The item *must* already be saved to the database
        // before calling thing function!
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

        // console.log("[model]", type, newIndex, JSON.stringify(dict))
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
        // This *saves* the new position to the database!
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
            var date = Helpers.getDateString(item.date)

            if (!_positions.hasOwnProperty(date)) {
                console.log("CREATING NEW POSITIONS")
                _positions[date] = positionsComponent.createObject(
                    root, {firstTodoIndex: Qt.binding(function(){return 0})})
                _keys.push(date)
                _refreshFirstIndex()
            }

            console.log("POSITIONS INDEX", date, _positions[date].firstTodoIndex)
            return _positions[date]
        } else {
            return _positions[""]
        }
    }

    function _firstTodoIndexBinding() {
        var myKey = key  // from ListIndices context
        var previousKey = _keysMap[myKey]  // from IndexedListModel context

        console.log("CHECKING INDEX", myKey, previousKey)

        if (!!previousKey) {
            return _positions[previousKey].lastIndex + 1 // IndexedListModel
        } else {
            return 0
        }
    }

    function _initPositions() {
        _positions = {}
        _keys = {}

        if (withSubState) {
            _positions[todayString] = positionsComponent.createObject(
                root, {key: todayString, firstTodoIndex: _firstTodoIndexBinding})
            _positions[tomorrowString] = positionsComponent.createObject(
                root, {key: tomorrowString, firstTodoIndex: _firstTodoIndexBinding})
            _positions[thisweekString] = positionsComponent.createObject(
                root, {key: thisweekString, firstTodoIndex: _firstTodoIndexBinding})
            _positions[somedayString] = positionsComponent.createObject(
                root, {key: somedayString, firstTodoIndex: _firstTodoIndexBinding})
            _keys = [todayString, tomorrowString, thisweekString, somedayString]
        } else {
            _positions[""] = positionsComponent.createObject(
                root, {key: "", firstTodoIndex: _firstTodoIndexBinding})
            _keys = [""]
        }

        _refreshFirstIndex()
    }

    function _refreshFirstIndex() {
        _keys.sort()  // string sorting because keys are strings

        var newMap = {}
        var previous = null

        for (var i in _keys) {
            if (previous !== null) {
                newMap[_keys[i]] = previous
            } else {
                newMap[_keys[i]] = null
            }

            previous = _keys[i]
        }

        _keysMap = newMap
    }

    // ----- internal -----

    property var _positions: ({})
    property var _keys: ([])
    property var _keysMap: ({})

    property Component positionsComponent: Component {
        ListIndices {
            key: ""
            model: root
            type: root.type
            rowidProperty: root.rowidProperty
            firstTodoIndex: 0 // TODO
        }
    }

    Component.onCompleted: {
        _initPositions()
    }
}
