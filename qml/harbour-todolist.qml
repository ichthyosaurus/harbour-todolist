import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "config" 1.0
import "js/storage.js" as Storage
import "pages"
import "components"

ApplicationWindow
{
    id: main
    property alias rawModel: mainModel
    property bool startupComplete: false

    property date today: getDate(0)
    property date tomorrow: getDate(1)

    property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'")
    property string timeFormat: qsTr("hh':'mm")
    property string fullDateFormat: qsTr("ddd d MMM yyyy")
    property string shortDateFormat: qsTr("d MMM yyyy")

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ListModel { id: mainModel }

    ConfigurationGroup {
        id: config
        path: "/apps/harbour-todolist"
        property date lastCarriedOverFrom
        property date lastCarriedOverTo
    }

    function getDate(offset, baseDate) {
        var currentDate = baseDate === undefined ? new Date() : baseDate;
        currentDate.setUTCDate(currentDate.getDate() + offset);
        currentDate.setUTCHours(0, 0, 0, 0);
        return currentDate;
    }

    function getDateString(date) {
        return new Date(date).toLocaleString(Qt.locale(), "yyyy-MM-dd");
    }

    function addItem(forDate, task, description, state, substate, createdOn) {
        state = Storage.defaultFor(state, EntryState.todo);
        substate = Storage.defaultFor(substate, EntrySubState.today);
        createdOn = Storage.defaultFor(createdOn, forDate);
        var weight = 1;
        var interval = 0;
        var category = "default";

        var entryid = Storage.addEntry(forDate, state, substate, createdOn,
                                       weight, interval, category, task, description);

        if (entryid === undefined) {
            console.error("failed to save new item", forDate, task);
            return;
        }

        rawModel.append({entryid: entryid, date: forDate, entrystate: state,
                            substate: substate, createdOn: createdOn, weight: weight,
                            interval: interval, category: category,
                            text: task, description: description});
    }

    function updateItem(which, mainState, subState, text, description) {
        if (mainState !== undefined) rawModel.setProperty(which, "entrystate", mainState);
        if (subState !== undefined) rawModel.setProperty(which, "substate", subState);
        if (text !== undefined) rawModel.setProperty(which, "text", text);
        if (description !== undefined) rawModel.setProperty(which, "description", description);

        var item = rawModel.get(which);
        Storage.updateEntry(item.entryid, item.date, item.entrystate, item.substate,
                            item.createdOn, item.weight, item.interval,
                            item.category, item.text, item.description);
    }

    function deleteItem(which) {
        Storage.deleteEntry(rawModel.get(which).entryid);
        rawModel.remove(which);
    }

    function markItemAs(which, mainState, subState, copyToDate) {
        updateItem(which, mainState, subState);
    }

    function copyItemTo(which, copyToDate) {
        var item = rawModel.get(which);
        copyToDate = Storage.defaultFor(copyToDate, getDate(1, item.date))
        addItem(copyToDate, item.text, item.description,
                EntryState.todo, EntrySubState.today, item.createdOn);
    }

    Component.onCompleted: {
        // TODO read config.* and import old unfinished entries from earlier
        // to be continued today

        var entries = Storage.getEntries();

        for (var i in entries) {
            rawModel.append(entries[i]);
        }

        startupComplete = true;
    }
}
