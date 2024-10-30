import QtQuick 2.0
import Todolist.Constants 1.0
import "../js/storage.js" as Storage

QtObject {
    id: root

    property ListModel model  // required
    property string type  // required
    property string rowidProperty: "rowid"

    property int todoCount: 0
    property int ignoredCount: 0
    property int doneCount: 0

    property int firstTodoIndex: 0
    readonly property int firstIgnoredIndex: firstTodoIndex + todoCount
    readonly property int firstDoneIndex: firstIgnoredIndex + ignoredCount
    readonly property int lastIndex: firstDoneIndex + doneCount - 1

    function updateState(index, newState, sortHint) {
        // This *saves* to the database!
        //
        // Pass a function(newItem, existingItem) as sortHint
        // to influence where the new item will be inserted.
        // Return true if the position is ok.
        // If the function never returns true, the item will
        // be added at the end of the section.

        var item = model.get(index)
        var oldIndex = index

        if (!EntryState.isValid(newState)) {
            console.error("bug: got an invalid state for updating",
                          oldIndex, "in", model, "-", newState)
            return
        }

        var oldState = item.entryState

        if (oldState === newState) {
            return // already up to date
        }

        model.setProperty(oldIndex, "entryState", newState)
        var newIndex = oldIndex
        var minIndex = 0

        if (newState === EntryState.Todo) {
            minIndex = firstTodoIndex
            newIndex = firstIgnoredIndex
                       - (oldState < newState ? 1 : 0)
            ++todoCount
        } else if (newState === EntryState.Ignored) {
            minIndex = firstIgnoredIndex
            newIndex = firstDoneIndex
                       - (oldState < newState ? 1 : 0)
            ++ignoredCount
        } else if (newState === EntryState.Done) {
            minIndex = firstDoneIndex
            newIndex = lastIndex
            ++doneCount
        }

        if (oldState === EntryState.Todo) {
            --todoCount
        } else if (oldState === EntryState.Ignored) {
            --ignoredCount
        } else if (oldState === EntryState.Done) {
            --doneCount
        }

        if (sortHint instanceof Function && newIndex > 0) {
            for (var i = newIndex-1; i >= minIndex; --i) {
                if (sortHint(item, model.get(i))) {
                    newIndex = i+1 - (oldState < newState ? 1 : 0)
                    break
                }
            }
        }

        model.move(oldIndex, newIndex, 1)
        Storage.moveItem(type, item[rowidProperty], newIndex)
    }
}
