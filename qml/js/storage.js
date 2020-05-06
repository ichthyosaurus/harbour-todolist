/*
 * This file is part of harbour-todolist.
 * Copyright (C) 2020  Mirian Margiani
 *
 * This file is based on storage.js from harbour-meteoswiss (same author),
 * which is also released under the GNU GPL v3+.
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

// .pragma library
// NOTE This can no longer be a library, because we need access to 'main.*' for
// showing notifications directly from here. This means, that this script
// is no longer shared between all QML components. Thus we MUST NOT include it
// anywhere other than in harbour-todolist.qml.

.import QtQuick.LocalStorage 2.0 as LS
.import "../constants/EntryState.js" as EntryState
.import "../constants/EntrySubState.js" as EntrySubState
.import "helpers.js" as Helpers

function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

function error(summary, details) {
    details = details.toString();
    console.error("Database error:", summary, details);
    dbErrorNotification.previewBody = summary; // short error description
    dbErrorNotification.summary = summary; // same as previewBody
    dbErrorNotification.body = details; // details on the error
    dbErrorNotification.publish();
}

var initialized = false

function getDatabase() {
    var db = LS.LocalStorage.openDatabaseSync("harbour-todolist", "1.0", "Todo List Data", 1000000);

    if (!initialized) {
        initialized = true;
        doInit(db);
    }

    return db;
}

function doInit(db) {
    // Database tables: (primary key in all-caps)
    // entries: ID, date, entryState, subState, createdOn, weight, interval, project, text, description
    // recurrings: ID, startDate, lastCopiedTo, entryState, intervalDays, project, text, description
    // projects: ID, name, entryState

    try {
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS entries(\
                date STRING NOT NULL,
                entryState INTEGER NOT NULL,
                subState INTEGER NOT NULL,
                createdOn STRING NOT NULL,
                weight INTEGER NOT NULL,
                interval INTEGER NOT NULL,
                project INTEGER NOT NULL,
                text TEXT NOT NULL,
                description TEXT
            );');
            tx.executeSql('CREATE TABLE IF NOT EXISTS recurrings(\
                startDate STRING NOT NULL,
                lastCopiedTo STRING,
                entryState INTEGER NOT NULL,
                intervalDays INTEGER NOT NULL,
                project INTEGER NOT NULL,
                text TEXT NOT NULL,
                description TEXT
            );');
            tx.executeSql('CREATE TABLE IF NOT EXISTS projects(\
                name TEXT NOT NULL,
                entryState INTEGER NOT NULL
            );');
            tx.executeSql('INSERT OR IGNORE INTO projects(rowid, name, entryState) VALUES(?, ?, ?)',
                          [defaultProjectId, qsTr("Default"), 0]);
        });
    } catch(e) {
        error(qsTr("Failed to initialize database"), e);
    }
}

function simpleQuery(query, values/*, getSelectedCount*/) {
    var db = getDatabase();
    var res = undefined;
    values = defaultFor(values, []);

    if (!query) {
        error(qsTr("Empty database query"), qsTr("This is a programming error. Please file a bug report."))
        return undefined;
    }

    try {
        db.transaction(function(tx) { res = tx.executeSql(query, values); });
    } catch(e) {
        error(qsTr("Database access failed"), e);
        console.error("-> values=", values);
        res = undefined;
    }

    return res;
}

function getProjects() {
    var q = simpleQuery('SELECT rowid, * FROM projects;', []);
    var res = []

    for (var i = 0; i < q.rows.length; i++) {
        var item = q.rows.item(i);

        res.push({entryId: item.rowid,
                     name: item.name,
                     entryState: parseInt(item.entryState, 10),
                 });
    }

    return res;
}

function getProject(entryId) {
    entryId = defaultFor(entryId, defaultProjectId);
    var q = simpleQuery('SELECT rowid, * FROM projects WHERE rowid=? LIMIT 1;', [entryId]);
    if (q.rows.length > 0) {
        var item = q.rows.item(0);
        return { entryId: item.rowid, name: item.name, entryState: parseInt(item.entryState, 10) };
    } else {
        return undefined;
    }
}

function addProject(name, entryState) {
    if (!name) return undefined;
    simpleQuery('INSERT INTO projects VALUES (?, ?)', [name, Number(entryState)])
    var q = simpleQuery('SELECT rowid FROM projects ORDER BY rowid DESC LIMIT 1;', []);
    if (q.rows.length > 0) return q.rows.item(0).rowid;
    else return undefined;
}

function updateProject(entryId, name, entryState) {
    if (entryId === undefined) {
        error(qsTr("Failed to update project"), qsTr("No internal project ID was provided."));
        console.error("->", name, entryState);
        return;
    }

    simpleQuery('UPDATE projects SET name=?, entryState=? WHERE rowid=?',
                [name, Number(entryState), entryId])
}

function deleteProject(entryId) {
    if (entryId === undefined) {
        error(qsTr("Failed to delete project"), qsTr("No internal project ID was provided."));
        return;
    } else if (entryId === defaultProjectId) {
        error(qsTr("Failed to delete project"), qsTr("The default project cannot be deleted."));
        return;
    }

    simpleQuery('DELETE FROM projects WHERE rowid=?', [entryId]);
    simpleQuery('DELETE FROM entries WHERE project=?', [entryId]);
}

function getRecurrings(forProject) {
    forProject = defaultFor(forProject, defaultProjectId);
    var q = simpleQuery('SELECT rowid, * FROM recurrings WHERE project=?;', [forProject]);
    var res = []

    for (var i = 0; i < q.rows.length; i++) {
        var item = q.rows.item(i);

        res.push({entryId: item.rowid,
                     startDate: new Date(item.startDate),
                     entryState: parseInt(item.entryState, 10),
                     intervalDays: parseInt(item.intervalDays, 10),
                     project: parseInt(item.project, 10),
                     text: item.text,
                     description: item.description
                 });
    }

    return res;
}

function addRecurring(startDate, entryState, intervalDays, project, text, description) {
    simpleQuery('INSERT INTO recurrings VALUES (?, ?, ?, ?, ?, ?, ?)', [
                    Helpers.getDateString(startDate), "",
                    Number(entryState), Number(intervalDays),
                    project, text, description
                ])

    var q = simpleQuery('SELECT rowid FROM recurrings ORDER BY rowid DESC LIMIT 1;', []);
    if (q.rows.length > 0) return q.rows.item(0).rowid;
    else return undefined;
}

function updateRecurring(entryId, startDate, entryState, intervalDays, project, text, description) {
    if (entryId === undefined) {
        error(qsTr("Failed to update recurring entry"), qsTr("No internal entry ID was provided."));
        console.error("->", startDate, text, intervalDays);
        return;
    }

    simpleQuery('UPDATE recurrings SET\
        startDate=?, entryState=?, intervalDays=?,
        project=?, text=?, description=? WHERE rowid=?', [
                    Helpers.getDateString(startDate),
                    Number(entryState), Number(intervalDays),
                    project, text, description, entryId
                ])
}

function deleteRecurring(entryId) {
    if (entryId === undefined) {
        error(qsTr("Failed to delete recurring entry"), qsTr("No internal entry ID was provided."));
        return;
    }

    simpleQuery('DELETE FROM recurrings WHERE rowid=?', [entryId]);
}

function _prepareEntries(q) {
    var res = []

    for (var i = 0; i < q.rows.length; i++) {
        var item = q.rows.item(i);

        res.push({entryId: item.rowid,
                     date: Helpers.getDate(0, new Date(item.date)),
                     entryState: parseInt(item.entryState, 10),
                     subState: parseInt(item.subState, 10),
                     createdOn: new Date(item.createdOn),
                     weight: parseInt(item.weight, 10),
                     interval: parseInt(item.interval, 10),
                     project: parseInt(item.project, 10),
                     text: item.text,
                     description: item.description
                 });
    }

    return res;
}

function getEntries(forProject) {
    forProject = defaultFor(forProject, defaultProjectId);
    var q = simpleQuery('SELECT rowid, * FROM entries WHERE project=? AND date >= ?;', [forProject, todayString]);
    return _prepareEntries(q);
}

function getArchivedEntries(forProject) {
    forProject = defaultFor(forProject, defaultProjectId);
    var q = simpleQuery('SELECT rowid, * FROM entries WHERE project=? AND date < ?;', [forProject, todayString]);
    return _prepareEntries(q);
}

function addEntry(date, entryState, subState, createdOn, weight, interval, project, text, description) {
    simpleQuery('INSERT INTO entries VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', [
        Helpers.getDateString(date),
        Number(entryState), Number(subState),
        Helpers.getDateString(createdOn),
        weight, interval, project, text, description
    ])

    var q = simpleQuery('SELECT rowid FROM entries ORDER BY rowid DESC LIMIT 1;', []);
    if (q.rows.length > 0) return q.rows.item(0).rowid;
    else return undefined;
}

function updateEntry(entryId, date, entryState, subState, createdOn, weight, interval, project, text, description) {
    if (entryId === undefined) {
        error(qsTr("Failed to update entry"), qsTr("No internal entry ID was provided."));
        console.error("->", date, text);
        return;
    }

    simpleQuery('UPDATE entries SET\
        date=?, entryState=?, subState=?,
        createdOn=?, weight=?, interval=?,
        project=?, text=?, description=? WHERE rowid=?', [
        Helpers.getDateString(date),
        Number(entryState), Number(subState),
        Helpers.getDateString(createdOn),
        weight, interval, project, text, description,
        entryId
    ])
}

function deleteEntry(entryId) {
    if (entryId === undefined) {
        error(qsTr("Failed to delete entry"), qsTr("No internal entry ID was provided."));
        return;
    }

    simpleQuery('DELETE FROM entries WHERE rowid=?', [entryId]);
}

function carryOverFrom(fromDate) {
    fromDate = defaultFor(fromDate, new Date("0000-01-01T00:00Z"));
    var fromDateString = Helpers.getDateString(fromDate)

    // copy all entry with entryState = todo and subState = today, that are older than today
    // (and, if we have fromDate, younger than fromDate), and set the new date to today's date
    var mainResult = simpleQuery('INSERT INTO entries(date, entryState, subState, createdOn, weight, interval, project, text, description)\
        SELECT date("now", "localtime"), entryState, subState, createdOn, weight, interval, project, text, description FROM entries\
            WHERE (date < date("now", "localtime")) AND (entryState = ?) AND (subState = ?) AND (date >= date(?)) ORDER BY rowid ASC',
                             [EntryState.todo, EntrySubState.today, fromDateString]);

    var updateResult = simpleQuery('UPDATE entries SET subState=? WHERE\
        (date < date("now", "localtime")) AND (entryState = ?) AND (subState = ?) AND (date >= date(?))',
                                   [EntrySubState.tomorrow, EntryState.todo,
                                    EntrySubState.today, fromDateString]);

    if (mainResult === undefined || updateResult === undefined) {
        if (mainResult === undefined) error(qsTr("Failed to carry over old entries"), qsTr("Copying old entries failed."));
        if (updateResult === undefined) error(qsTr("Failed to carry over old entries"), qsTr("Updating old entries failed."));
        return false;
    } else {
        console.log("entries carried over:", mainResult.rowsAffected);
        return true;
    }
}

function copyRecurrings() {
    var whereClause = '(entryState = ?) AND lastCopiedTo != ? AND ' +
        '(julianday(?, "localtime") - julianday(startDate, "localtime")) % intervalDays = 0';

    var mainResult = simpleQuery(
        'INSERT INTO entries(date, entryState, subState, createdOn, weight, interval, project, text, description) ' +
            'SELECT ?, 0, 0, ?, 1, intervalDays, project, text, description FROM recurrings WHERE ' + whereClause,
        [todayString, todayString, EntryState.todo, todayString, todayString]
    );

    var updateResult = 0;
    if (mainResult !== undefined && mainResult.rowsAffected > 0) {
        // only update if something was copied
        updateResult = simpleQuery('UPDATE recurrings SET lastCopiedTo=? WHERE ' + whereClause,
            [todayString, EntryState.todo, todayString, todayString]
        );
    }

    if (mainResult === undefined || updateResult === undefined) {
        if (mainResult === undefined) error(qsTr("Failed to update recurring entries"), qsTr("Copying new entries failed."));
        if (updateResult === undefined) error(qsTr("Failed to update recurring entries"), qsTr("Updating reference entries failed."));
        console.log("recurrings failed for", todayString)
        return false;
    } else {
        console.log(mainResult.rowsAffected, "recurrings for", todayString);
        return true;
    }
}
