/*
 * This file is part of harbour-todolist.
 *
 * SPDX-FileCopyrightText: 2020-2021 Mirian Margiani
 * SPDX-FileCopyrightText: 2020 cage
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * harbour-todolist is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * harbour-todolist is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import "constants" 1.0
import "js/storage.js" as Storage
import "js/helpers.js" as Helpers
import "pages"

ApplicationWindow
{
    id: main
    property ListModel currentEntriesModel: ListModel { }
    property ListModel projectsModel: ListModel { }
    property ListModel recurringsModel: ListModel { }
    property ListModel archiveModel: ListModel { }
    property alias configuration: config

    property bool startupComplete: false
    property string currentProjectName: ""
    property int currentProjectId: defaultProjectId
    property date lastSelectedCategory: today

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

    signal fakeNavigateLeft()
    signal fakeNavigateRight()

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Notification {
        id: dbErrorNotification
        appIcon: "image://theme/icon-lock-warning"
        previewSummary: qsTr("Database Error")
        appName: main.appName

        // previewBody, summary, and body have to be provided by Storage
        previewBody: "" // short error description
        summary: "" // same as previewBody
        body: "" // details on the error
    }

    readonly property int defaultProjectId: 1
    ConfigurationGroup {
        id: config
        path: "/apps/harbour-todolist"
        property date lastCarriedOverFrom
        property int currentProject
        property var activeProjects: []
    }

    Timer {
        id: timer
        // Run every 1h to check for changes.
        interval: 3600000
        repeat: true
        onTriggered: {
            refreshDates();
        }
    }

    function addItem(forDate, task, description, entryState, subState, createdOn, interval) {
        entryState = Storage.defaultFor(entryState, EntryState.todo);
        subState = Storage.defaultFor(subState, EntrySubState.today);
        createdOn = Storage.defaultFor(createdOn, forDate);
        var weight = 1;
        interval = Storage.defaultFor(interval, 0);
        var project = config.currentProject;

        var entryId = Storage.addEntry(forDate, entryState, subState, createdOn,
                                       weight, interval, project, task, description);

        if (entryId === undefined) {
            console.error("failed to save new item", forDate, task);
            return;
        }

        currentEntriesModel.append({entryId: entryId, date: forDate, entryState: entryState,
                            subState: subState, createdOn: createdOn, weight: weight,
                            interval: interval, project: project,
                            text: task, description: description});
    }

    function addNormalTask(forDate, task, description, projectId, entryState, subState, createdOn, interval) {
        entryState = Storage.defaultFor(entryState, EntryState.todo);
        subState = Storage.defaultFor(subState, EntrySubState.today);
        createdOn = Storage.defaultFor(createdOn, forDate);
        var weight = 1;
        interval = Storage.defaultFor(interval, 0);

        // NOTE: make a new version of addEntry that returns the latest entry as an object
        var entryId = Storage.addEntry(
            forDate, entryState, subState, createdOn, weight, interval, projectId, task, description);

        if (entryId === undefined) {
            console.error("failed to save new item", forDate, task);
            return;
        }

        // NOTE: the obejct as returned by above note can then be added directly as-is here
        currentEntriesModel.append({
            entryId: entryId,
            date: forDate,
            entryState: entryState,
            subState: subState,
            createdOn: createdOn,
            weight: weight,
            interval: interval,
            project: projectId,
            text: task,
            description: description
        });
    }

    // Update an entry in the database and in currentEntriesModel. This is not intended to be used
    // for archived entries, as the archive should be immutable.
    function updateItem(which, entryState, subState, text, description, project) {
        if (entryState !== undefined) currentEntriesModel.setProperty(which, "entryState", entryState);
        if (subState !== undefined) currentEntriesModel.setProperty(which, "subState", subState);
        if (text !== undefined) currentEntriesModel.setProperty(which, "text", text);
        if (description !== undefined) currentEntriesModel.setProperty(which, "description", description);

        var item = currentEntriesModel.get(which);
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
        Storage.deleteEntry(currentEntriesModel.get(which).entryId);
        currentEntriesModel.remove(which);
    }

    // Copy an entry in the database and in currentEntriesModel. This is not intended to be used
    // for archived entries, as the archive should be immutable.
    function copyItemTo(which, copyToDate) {
        var item = currentEntriesModel.get(which);
        copyToDate = Storage.defaultFor(copyToDate, Helpers.getDate(1, item.date))
        addItem(copyToDate, item.text, item.description,
                EntryState.todo, EntrySubState.today, item.createdOn);
    }

    // Move an entry in the database and in currentEntriesModel. This is not intended to be used
    // for archived entries, as the archive should be immutable.
    function moveItemTo(which, moveToDate) {
        var item = currentEntriesModel.get(which);

        if (Storage.defaultFor(moveToDate, "fail") === "fail") {
            console.log("error: failed to move item", which, moveToDate);
        }

        addItem(moveToDate, item.text, item.description,
                item.entryState, item.subState, item.createdOn);
        deleteItem(which);
    }

    function addRecurring(text, description, intervalDays, startDate) {
        var entryState = EntryState.todo;
        intervalDays = Storage.defaultFor(intervalDays, 1);
        var project = config.currentProject;
        startDate = Helpers.getDate(0, Storage.defaultFor(startDate, today));

        var addForToday = false;
        var daysDiff = Math.round((startDate.getTime() - today.getTime()) / 24 / 3600 / 1000)

        if (startDate.getTime() <= today.getTime() && daysDiff % intervalDays === 0) {
            addForToday = true;
        }

        var entryId = Storage.addRecurring(startDate, entryState, intervalDays, project, text, description, addForToday);
        if (entryId === undefined) {
            console.error("failed to save new recurring item", text, intervalDays);
            return;
        }

        recurringsModel.append({entryId: entryId, startDate: startDate, entryState: entryState,
                                intervalDays: intervalDays, project: project,
                                text: text, description: description});

        if (addForToday) {
            addItem(today, text.trim(), description.trim(),
                    entryState, EntrySubState.today, today, intervalDays);
        }
    }

    function updateRecurring(which, startDate, entryState, intervalDays, text, description, project) {
        if (startDate !== undefined) recurringsModel.setProperty(which, "startDate", startDate);
        if (entryState !== undefined) recurringsModel.setProperty(which, "entryState", entryState);
        if (intervalDays !== undefined) recurringsModel.setProperty(which, "intervalDays", intervalDays);
        if (text !== undefined) recurringsModel.setProperty(which, "text", text);
        if (description !== undefined) recurringsModel.setProperty(which, "description", description);

        var item = recurringsModel.get(which);
        if (project === undefined) project = item.project;

        Storage.updateRecurring(item.entryId, item.startDate, item.entryState, item.intervalDays,
                                project, item.text, item.description);

        if (project !== item.project) {
            // Switch to the new project if it was changed.
            // This reloads all entries, so we don't have to manually update
            // the item in recurringsModel.
            setCurrentProject(project);
        }
    }

    function deleteRecurring(which) {
        Storage.deleteRecurring(recurringsModel.get(which).entryId);
        recurringsModel.remove(which);
    }

    function getProject(projectId) {
        return Storage.getProject(projectId)
    }

    function addProject(name, entryState) {
        entryState = Storage.defaultFor(entryState, EntryState.todo);
        name = Storage.defaultFor(name, "")
        var entryId = Storage.addProject(name, entryState);

        if (entryId === undefined) {
            console.error("failed to save new project", name, entryState);
            return;
        } else {
            projectsModel.append({entryId: entryId, entryState: entryState, name: name});
        }
    }

    function updateProject(which, name, entryState) {
        if (name !== undefined) {
            projectsModel.setProperty(which, "name", name);
        }
        if (entryState !== undefined) projectsModel.setProperty(which, "entryState", entryState);
        var item = projectsModel.get(which);
        Storage.updateProject(item.entryId, item.name, item.entryState);
    }

    function deleteProject(which) {
        var item = projectsModel.get(which);

        if (config.currentProject === item.entryId) {
            setCurrentProject(defaultProjectId);
        } else if (item.entryId === defaultProjectId) {
            // This should not be reachable.
            return;
        }

        Storage.deleteProject(item.entryId);
        projectsModel.remove(which);
    }

    function setCurrentProject(entryId) {
        entryId = Storage.defaultFor(entryId, defaultProjectId);
        config.currentProject = entryId;
        var project = Storage.getProject(config.currentProject);

        if (project === undefined) {
            // if the requested project is not available, reset it to the default project
            setCurrentProject(defaultProjectId);
        } else {
            currentProjectId = project.entryId;
            updateProjectEntries()
        }
    }

    function updateProjectEntries() {
        startupComplete = false;
        lastSelectedCategory = today;

        currentEntriesModel.clear();
        recurringsModel.clear();
        archiveModel.clear();

        config.activeProjects.forEach(function (projId, index) {
            Storage.getEntries(projId).forEach(function (entry, index) {
                currentEntriesModel.append(entry)
            })
            Storage.getRecurrings(projId).forEach(function (entry, index) {
                recurringsModel.append(entry)
            })
        })

        startupComplete = true;

    }

    function loadArchive() {
        config.activeProjects.forEach(function(projId, index) {
            Storage.getArchivedEntries(projId).forEach(function(entry, index) {
                archiveModel.append(entry)
            })
        })
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
        // Start with true to force a refresh on application startup.
        refreshDates(true);
        projectsModel.clear();
        var projects = Storage.getProjects();
        for (var i in projects) projectsModel.append(projects[i]);
        // Start the timer to check for date changes every hour.
        timer.start();
    }
}
