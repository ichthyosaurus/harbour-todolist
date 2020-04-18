/*
 * This file is part of harbour-todolist.
 * Copyright (C) 2020  Mirian Margiani
 *
 * harbour-todolist is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-todolist is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-todolist.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import "constants" 1.0
import "js/storage.js" as Storage
import "js/helpers.js" as Helpers
import "sf-about-page/about.js" as About
import "pages"

ApplicationWindow
{
    id: main
    property alias rawModel: mainModel
    property alias projectsModel: mainProjectsModel
    property alias recurringsModel: mainRecurringsModel
    property alias configuration: config

    property bool startupComplete: false
    property string currentProjectName: ""

    property date today: Helpers.getDate(0)
    property date tomorrow: Helpers.getDate(1)
    property date someday: Helpers.getDate(0, new Date("9999-01-01T00:00Z"))
    property string todayString: Helpers.getDateString(today)
    property string tomorrowString: Helpers.getDateString(tomorrow)
    property string somedayString: Helpers.getDateString(someday)

    readonly property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'")
    readonly property string timeFormat: qsTr("hh':'mm")
    readonly property string fullDateFormat: qsTr("ddd d MMM yyyy")
    readonly property string shortDateFormat: qsTr("d MMM yyyy")

    signal fakeNavigateLeft()
    signal fakeNavigateRight()

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ListModel { id: mainModel }
    ListModel { id: mainProjectsModel }
    ListModel { id: mainRecurringsModel }

    Notification {
        id: dbErrorNotification
        appIcon: "image://theme/icon-lock-warning"
        previewSummary: qsTr("Database Error")
        appName: qsTr("Todo List")

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

        rawModel.append({entryId: entryId, date: forDate, entryState: entryState,
                            subState: subState, createdOn: createdOn, weight: weight,
                            interval: interval, project: project,
                            text: task, description: description});
    }

    function updateItem(which, entryState, subState, text, description) {
        if (entryState !== undefined) rawModel.setProperty(which, "entryState", entryState);
        if (subState !== undefined) rawModel.setProperty(which, "subState", subState);
        if (text !== undefined) rawModel.setProperty(which, "text", text);
        if (description !== undefined) rawModel.setProperty(which, "description", description);

        var item = rawModel.get(which);
        Storage.updateEntry(item.entryId, item.date, item.entryState, item.subState,
                            item.createdOn, item.weight, item.interval,
                            item.project, item.text, item.description);
    }

    function deleteItem(which) {
        Storage.deleteEntry(rawModel.get(which).entryId);
        rawModel.remove(which);
    }

    function copyItemTo(which, copyToDate) {
        var item = rawModel.get(which);
        copyToDate = Storage.defaultFor(copyToDate, Helpers.getDate(1, item.date))
        addItem(copyToDate, item.text, item.description,
                EntryState.todo, EntrySubState.today, item.createdOn);
    }

    function addRecurring(text, description, intervalDays, startDate) {
        var entryState = EntryState.todo;
        intervalDays = Storage.defaultFor(intervalDays, 1);
        var project = config.currentProject;
        startDate = Storage.defaultFor(startDate, new Date(NaN));
        if (isNaN(startDate.valueOf())) startDate = today;

        var entryId = Storage.addRecurring(startDate, entryState, intervalDays, project, text, description);

        if (entryId === undefined) {
            console.error("failed to save new recurring item", text, intervalDays);
            return;
        }

        recurringsModel.append({entryId: entryId, startDate: startDate, entryState: entryState,
                                intervalDays: intervalDays, project: project,
                                text: text, description: description});
    }

    function updateRecurring(which, startDate, entryState, intervalDays, text, description) {
        if (startDate !== undefined) recurringsModel.setProperty(which, "startDate", startDate);
        if (entryState !== undefined) recurringsModel.setProperty(which, "entryState", entryState);
        if (intervalDays !== undefined) recurringsModel.setProperty(which, "intervalDays", intervalDays);
        if (text !== undefined) recurringsModel.setProperty(which, "text", text);
        if (description !== undefined) recurringsModel.setProperty(which, "description", description);

        var item = recurringsModel.get(which);
        Storage.updateRecurring(item.entryId, item.startDate, item.entryState, item.intervalDays,
                                item.project, item.text, item.description);
    }

    function deleteRecurring(which) {
        Storage.deleteRecurring(recurringsModel.get(which).entryId);
        recurringsModel.remove(which);
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
            currentProjectName = name;
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
            currentProjectName = project.name;
            startupComplete = false;
            rawModel.clear();
            var entries = Storage.getEntries(config.currentProject);
            for (var i in entries) rawModel.append(entries[i]);
            startupComplete = true;

            recurringsModel.clear();
            entries = Storage.getRecurrings(config.currentProject);
            for (i in entries) recurringsModel.append(entries[i]);
        }
    }

    Component.onCompleted: {
        About.VERSION_NUMBER = VERSION_NUMBER;

        if (Storage.carryOverFrom(config.lastCarriedOverFrom)) {
            config.lastCarriedOverFrom = Helpers.getDate(-1, today);
        }
        Storage.copyRecurrings();
        setCurrentProject(config.currentProject);

        projectsModel.clear();
        var projects = Storage.getProjects();
        for (var i in projects) projectsModel.append(projects[i]);
    }
}
