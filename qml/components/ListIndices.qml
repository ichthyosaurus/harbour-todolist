import QtQuick 2.0
import Todolist.Constants 1.0
import "../js/storage.js" as Storage

QtObject {
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

    function updateState(index, newState) {
        // This *saves* to the database!

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

        if (newState === EntryState.Todo) {
            newIndex = firstIgnoredIndex
                    - (oldState < newState ? 1 : 0)
            ++todoCount
        } else if (newState === EntryState.Ignored) {
            newIndex = firstDoneIndex
                    - (oldState < newState ? 1 : 0)
            ++ignoredCount
        } else if (newState === EntryState.Done) {
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

        model.move(oldIndex, newIndex, 1)
        Storage.moveItem(type, item[rowidProperty], newIndex)
    }
}
