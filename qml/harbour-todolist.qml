/*
 * This file is part of harbour-todolist.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import Opal.About 1.0 as A
import Opal.SupportMe 1.0 as M
import Todolist.Constants 1.0
import "js/storage.js" as Storage
import "js/helpers.js" as Helpers
import "components"
import "pages"

ApplicationWindow {
    id: main

    property ListModel currentEntriesModel: ListModel {
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
                var compare = get(i).dateString
                i += _dateCounts[compare]

                if (compare === item.dateString) {
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
                var compare = get(i).dateString

                if (compare === item.dateString) {
                    for (var x = i; x < i+_dateCounts[compare]; ++x) {
                        newIndex = x

                        if (get(x).entryState > newState) {
                            newIndex = newIndex - (item.entryState < newState ? 1 : 0)
                            break
                        }
                    }

                    break
                } else {
                    i += _dateCounts[compare]
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
    property IndexedListModel projectsModel: IndexedListModel {
        type: "projects"
    }
    property IndexedListModel recurringsModel: IndexedListModel {
        type: "recurrings"

        function sortHint(newItem, existingItem) {
            // sort items by interval by default
            return existingItem.intervalDays <= newItem.intervalDays
        }
    }
    property ListModel archiveModel: ListModel { }
    property alias configuration: config

    property bool startupComplete: false
    property string currentProjectName: ""
    property int currentProjectId: defaultProjectId
    property date lastSelectedCategory: today
    property bool loading: false

    property date today: Helpers.getDate(0)
    property date tomorrow: Helpers.getDate(1)
    property date thisweek: Helpers.getDate(0, new Date("8888-01-01T00:00Z"))
    property date someday: Helpers.getDate(0, new Date("9999-01-01T00:00Z"))
    property string todayString: Helpers.getDateString(today)
    property string tomorrowString: Helpers.getDateString(tomorrow)
    property string thisweekString: Helpers.getDateString(thisweek)
    property string somedayString: Helpers.getDateString(someday)

    readonly property string appName: qsTr("To-do List", "the app's name")
    readonly property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'", "date format including date and time but no weekday")
    readonly property string timeFormat: qsTr("hh':'mm", "format for times")
    readonly property string fullDateFormat: qsTr("ddd d MMM yyyy", "date format including weekday")
    readonly property string shortDateFormat: qsTr("d MMM yyyy", "date format without weekday")

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    // We have to explicitly set the \c _defaultPageOrientations property
    // to \c Orientation.All so the page stack's default placeholder page
    // will be allowed to be in landscape mode. (The default value is
    // \c Orientation.Portrait.) Without this setting, pushing multiple pages
    // to the stack using \c animatorPush() while in landscape mode will cause
    // the view to rotate back and forth between orientations.
    // [as of 2021-02-17, SFOS 3.4.0.24, sailfishsilica-qt5 version 1.1.110.3-1.33.3.jolla]
    _defaultPageOrientations: Orientation.All
    allowedOrientations: Orientation.All

    A.ChangelogNews {
        changelogList: Qt.resolvedUrl("Changelog.qml")
    }

    M.AskForSupport {
        contents: Component {
            MySupportDialog {}
        }
    }

    Notification {
        id: dbErrorNotification
        appIcon: "image://theme/icon-lock-warning"
        previewSummary: qsTr("Database Error")
        appName: main.appName

        // previewBody, summary, and body have to be provided by Storage
        previewBody: "" // short error description
        summary: "" // same as previewBody
        body: "" // details on the error

        Component.onCompleted: {
            Storage.dbErrorNotification = dbErrorNotification
        }
    }

    WorkerScript {
        id: worker
        source: "js/worker.js"

        property int batchCount: 0
        property int series: 0

        onMessage: {
            if (messageObject.event === 'loadingEntriesStarted') {
                console.log("[main] preparing to load entries:",
                            messageObject.count, "for", messageObject.model,
                            messageObject.series)
                loading = true
                series = messageObject.series
                var model = _selectModel(messageObject)

                if (model.hasOwnProperty('reset')) {
                    model.reset()
                } else {
                    model.clear()
                }
            } else if (messageObject.event === 'loadingEntriesBatch') {
                if (messageObject.series !== series) {
                    console.log("[main] discarding loaded entries for " +
                                "outdated series", messageObject.series,
                                "- expected", series)
                    return
                }

                batchCount += 1
                console.log("[main] received entries: batch no.",
                            batchCount, "for", messageObject.model,
                            messageObject.series)
                var model = _selectModel(messageObject)

                if (messageObject.model === 'recurrings' ||
                        messageObject.model === 'entries') {
                    for (var i in messageObject.entries) {
                        model.addItem(messageObject.entries[i], null, false)
                    }
                } else {
                    for (var j in messageObject.entries) {
                        model.append(messageObject.entries[j])
                    }
                }
            } else if (messageObject.event === 'loadingEntriesFinished') {
                console.log("[main] loading finished for",
                            messageObject.model, messageObject.series)

                if (messageObject.series === series) {
                    loading = false
                }
            } else {
                Storage.error(qsTr("Internal error"),
                              qsTr("An unknown worker message cannot be handled.") +
                              "\n" + JSON.stringify(messageObject))
            }
        }

        function _selectModel(message) {
            if (message.model === 'entries') {
                return currentEntriesModel
            } else if (message.model === 'recurrings') {
                return recurringsModel
            } else if (message.model === 'archive') {
                return archiveModel
            }

            return null
        }

        Component.onCompleted: {
            Storage.worker = worker
        }
    }

    readonly property int defaultProjectId: 1
    ConfigurationGroup {
        id: config
        path: "/apps/harbour-todolist"
        property date lastCarriedOverFrom
        property int currentProject
    }

    Timer {
        id: timer
        // Run every 1h to check for changes.
        interval: 3600000
        repeat: true
        onTriggered: {
            refreshDates()
        }
    }

    function addItem(forDate, task, description,
                     entryState, subState, createdOn, interval) {
        entryState = Storage.defaultFor(entryState, EntryState.Todo);
        subState = Storage.defaultFor(subState, EntrySubState.Today);
        createdOn = Storage.defaultFor(createdOn, forDate);
        var weight = 0;
        interval = Storage.defaultFor(interval, 0);
        var project = config.currentProject;

        var newItem = Storage.addEntry(
            forDate, entryState, subState, createdOn,
            weight, interval, project, task, description)

        if (!!newItem) {
            currentEntriesModel.addItem(newItem, null, true)
        }
    }

    // Update an entry in the database and in currentEntriesModel. This is not intended to be used
    // for archived entries, as the archive should be immutable.
    function updateItem(which, entryState, subState, text, description, project) {
        // WARNING: this function changes the item's index. The index passed
        // as "which" will no longer be valid after calling this function!
        if (subState !== undefined) currentEntriesModel.setProperty(which, "subState", subState);
        if (text !== undefined) currentEntriesModel.setProperty(which, "text", text);
        if (description !== undefined) currentEntriesModel.setProperty(which, "description", description);

        var item = currentEntriesModel.get(which);

        if (entryState !== undefined) {
            currentEntriesModel.updateState(which, entryState)
        }

        Storage.updateEntry(item.entryId, item.date, item.entryState, item.subState,
                            item.createdOn, item.weight, item.interval,
                            (project === undefined ? item.project : project),
                            item.text, item.description);

        if (project !== undefined && project !== item.project) {
            // Switch to the new project if it was changed.
            // This reloads all entries, so we don't have to manually update
            // the item in currentEntriesModel.
            setCurrentProject(project);
        }
    }

    // Delete an entry from the database and from currentEntriesModel. This is not intended to be used
    // for archived entries, as the archive should be immutable.
    function deleteItem(which) {
        var rowid = currentEntriesModel.get(which).entryId
        Storage.deleteEntry(rowid)
        currentEntriesModel.removeItem(which)
    }

    // Copy an entry in the database and in currentEntriesModel. This is not intended to be used
    // for archived entries, as the archive should be immutable.
    function copyItemTo(which, copyToDate) {
        var item = currentEntriesModel.get(which)
        copyToDate = Storage.defaultFor(copyToDate, Helpers.getDate(1, item.date))

        addItem(copyToDate, item.text, item.description,
                EntryState.Todo, EntrySubState.Today, item.createdOn);
    }

    // Move an entry in the database and in currentEntriesModel. This is not intended to be used
    // for archived entries, as the archive should be immutable.
    function moveItemTo(which, moveToDate) {
        var item = currentEntriesModel.get(which)

        if (Storage.defaultFor(moveToDate, "fail") === "fail") {
            console.error("failed to move item", which, moveToDate)
            return
        }

        var text = item.text
        var description = item.description
        var entryState = item.entryState
        var subState = item.subState
        var createdOn = item.createdOn

        deleteItem(which)  // adding will change indexes, so delete first
        addItem(moveToDate, text, description,
                entryState, subState, createdOn)
    }

    function moveAndMarkItemTo(which, moveToDate, entryState, subState) {
        // WARNING: this function changes indices!

        var item = currentEntriesModel.get(which)

        if (Storage.defaultFor(moveToDate, "fail") === "fail") {
            console.error("failed to move item", which, moveToDate)
            return
        }

        if (entryState === undefined) subState = item.entryState
        if (subState === undefined) subState = item.subState

        var text = item.text
        var description = item.description
        var createdOn = item.createdOn

        deleteItem(which)  // adding will change indexes, so delete first
        addItem(moveToDate, text, description,
                entryState, subState, createdOn)
    }

    function addRecurring(text, description, intervalDays, startDate) {
        var entryState = EntryState.Todo;
        intervalDays = Storage.defaultFor(intervalDays, 1);
        var project = config.currentProject;
        startDate = Helpers.getDate(0, Storage.defaultFor(startDate, today));

        var addForToday = false;
        var daysDiff = Math.round((startDate.getTime() - today.getTime()) / 24 / 3600 / 1000)

        if (startDate.getTime() <= today.getTime() && daysDiff % intervalDays === 0) {
            addForToday = true;
        }

        var newItem = Storage.addRecurring(
            startDate, entryState, intervalDays,
            project, text, description, addForToday)

        if (!!newItem) {
            recurringsModel.addItem(newItem, recurringsModel.sortHint, true)
        }

        if (addForToday) {
            addItem(today, text.trim(), description.trim(),
                    entryState, EntrySubState.Today, today, intervalDays)
        }
    }

    function updateRecurring(which, startDate, entryState, intervalDays, text, description, project) {
        if (startDate !== undefined) recurringsModel.setProperty(which, "startDate", startDate);
        if (intervalDays !== undefined) recurringsModel.setProperty(which, "intervalDays", intervalDays);
        if (text !== undefined) recurringsModel.setProperty(which, "text", text);
        if (description !== undefined) recurringsModel.setProperty(which, "description", description);

        var item = recurringsModel.get(which);
        if (project === undefined) project = item.project;

        if (entryState !== undefined) {
            recurringsModel.updateState(
                which, entryState, recurringsModel.sortHint)
        }

        Storage.updateRecurring(
            item.entryId, item.startDate, item.entryState,
            item.intervalDays, project, item.text, item.description)

        if (project !== item.project) {
            // Switch to the new project if it was changed.
            // This reloads all entries, so we don't have to manually update
            // the item in recurringsModel.
            setCurrentProject(project)
        }
    }

    function deleteRecurring(which) {
        var rowid = recurringsModel.get(which).entryId
        Storage.deleteRecurring(rowid)
        recurringsModel.removeItem(which)
    }

    function addProject(name, entryState) {
        var newProject = Storage.addProject(name, entryState)
        if (!!newProject) {
            projectsModel.addItem(newProject, null, true)
        }
    }

    function updateProject(which, name, entryState) {
        var item = projectsModel.get(which)

        if (name !== undefined) {
            projectsModel.setProperty(which, "name", name)
            currentProjectName = name
        }

        if (entryState !== undefined) {
            projectsModel.updateState(which, entryState)
        }

        Storage.updateProject(item.entryId, item.name, item.entryState)
    }

    function deleteProject(which) {
        var rowid = projectsModel.get(which).entryId

        if (rowid === config.currentProject) {
            setCurrentProject(defaultProjectId)
        } else if (rowid === defaultProjectId) {
            console.error("[bug] trying to delete the default project")
            return
        }

        Storage.deleteProject(rowid)
        projectsModel.removeItem(which)
    }

    function setCurrentProject(entryId) {
        console.log("[main] activating project", entryId)
        entryId = Storage.defaultFor(entryId, defaultProjectId);
        config.currentProject = entryId;
        var project = Storage.getProject(config.currentProject);

        console.log("[main] got project data:", JSON.stringify(project))

        if (project === undefined) {
            // if the requested project is not available, reset it to the default project
            setCurrentProject(defaultProjectId);
            console.warn("[main] failed to activate project", entryId)
        } else {
            lastSelectedCategory = today;
            currentProjectName = project.name;
            currentProjectId = project.entryId;
            startupComplete = false;
            archiveModel.clear();

            Storage.loadEntries(config.currentProject, 'entries');
            Storage.loadRecurrings(config.currentProject, 'recurrings');
            startupComplete = true;
        }
    }

    function loadArchive() {
        loading = true
        Storage.loadArchive(config.currentProject, 'archive');
    }

    // Resets all date properties after a date change. The force parameter can be used to force a model refresh.
    function refreshDates(force) {
        var oldToday = todayString;

        today = Helpers.getDate(0);
        todayString = Helpers.getDateString(today);

        // If the date did not change, do not update anything else.
        if (!force && oldToday === todayString) {
            return;
        }

        tomorrow = Helpers.getDate(1);
        thisweek = Helpers.getDate(0, new Date("8888-01-01T00:00Z"));
        someday = Helpers.getDate(0, new Date("9999-01-01T00:00Z"));
        tomorrowString = Helpers.getDateString(tomorrow);
        thisweekString = Helpers.getDateString(thisweek);
        somedayString = Helpers.getDateString(someday);

        // Update the database and models according to the new date properties.
        if (Storage.carryOverFrom(config.lastCarriedOverFrom)) {
            config.lastCarriedOverFrom = Helpers.getDate(-1, today);
        }
        Storage.copyRecurrings();
        setCurrentProject(config.currentProject);
    }

    Component.onCompleted: {
        Storage.defaultProjectId = defaultProjectId
        Storage.todayString = todayString

        // Start with true to force a refresh on application startup.
        refreshDates(true)
        projectsModel.reset()

        var projects = Storage.getProjects()
        for (var i in projects) {
            projectsModel.addItem(projects[i], null, false)
        }

        // Start the timer to check for date changes every hour.
        timer.start()
    }
}
