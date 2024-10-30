/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-FileCopyrightText: 2020 cage
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

.pragma library
.import "storage_helper.js" as DB
.import "helpers.js" as Helpers
.import "../constants/EntryState.js" as EntryState
.import "../constants/EntrySubState.js" as EntrySubState

//
// BEGIN External configuration
// These values must be populated in harbour-todolist.qml
// as soon as possible after the app has been started.
//

var dbErrorNotification = null
var worker = null
var defaultProjectId = 1
var todayString = ''


//
// BEGIN Database configuration
//

function dbOk() { return DB.dbOk }
var isSameValue = DB.isSameValue
var defaultFor = DB.defaultFor

DB.dbName = "harbour-todolist"
DB.dbDescription = "Todo List Data"
DB.dbSize = 1000000

DB.dbMigrations = [
    // Database versions do not correspond to app versions.

    [1, function(tx){
        // Future versions must increase in integer steps.

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
        );')
        tx.executeSql('CREATE TABLE IF NOT EXISTS recurrings(\
            startDate STRING NOT NULL,
            lastCopiedTo STRING,
            entryState INTEGER NOT NULL,
            intervalDays INTEGER NOT NULL,
            project INTEGER NOT NULL,
            text TEXT NOT NULL,
            description TEXT
        );')
        tx.executeSql('CREATE TABLE IF NOT EXISTS projects(\
            name TEXT NOT NULL,
            entryState INTEGER NOT NULL
        );')
        tx.executeSql('\
            INSERT OR IGNORE INTO projects(
                rowid, name, entryState
            ) VALUES (?, ?, ?)',
            [defaultProjectId, qsTr("Default"), 0])
    }],
    [2, function(tx){
        // This version introduces support for vacuuming the
        // database, and adds sorting to the projects table.
        //
        // The rowid column is created explicitly here because
        // it is used as foreign key in other tables. Autoincrement
        // is not necessary because all data referencing a project
        // is deleted when the project is deleted.
        //
        // https://sqlite.org/lang_createtable.html#rowid
        // https://sqlite.org/autoinc.html
        // https://sqlite.org/lang_vacuum.html

        DB.createSettingsTable(tx)

        tx.executeSql('\
            CREATE TABLE IF NOT EXISTS projects_temp(
                rowid INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                entryState INTEGER NOT NULL,
                seq INTEGER
        );')

        tx.executeSql('\
            INSERT INTO projects_temp(
                rowid,
                name,
                entryState,
                seq
            ) SELECT
                rowid,
                name,
                entryState,
                (ROW_NUMBER() OVER(ORDER BY entryState ASC, rowid ASC))
            FROM projects
        ;')

//        WITH cte AS (SELECT *, ROW_NUMBER() OVER(ORDER BY entryState ASC, rowid ASC) AS rn FROM _projects)
//        UPDATE _projects SET seq = (SELECT rn FROM cte WHERE cte.rowid = _projects.rowid)

        tx.executeSql('DROP TABLE projects;')
        tx.executeSql('ALTER TABLE projects_temp RENAME TO _projects;')

        DB.makeTableSortable(tx, '_projects', 'seq')
    }],

    // add new versions here...
    //
    // remember: versions must be numeric, e.g. 0.1 but not 0.1.1
    // important: increase versions in integer steps for this app
]


//
// BEGIN App database functions
//

var simpleQuery = DB.simpleQuery

function error(summary, details) {
    details = details.toString();
    console.error("Database error:", summary, details);

    if (!!dbErrorNotification) {
        dbErrorNotification.previewBody = summary // short error description
        dbErrorNotification.summary = summary // same as previewBody
        dbErrorNotification.body = details // details about the error
        dbErrorNotification.publish()
    } else {
        console.log("note: db error notification is not available")
    }
}

function getProjects() {
    var q = simpleQuery('\
        SELECT rowid, *
        FROM projects
        ORDER BY
            entryState ASC,
            seq ASC
    ;')
    var res = []

    for (var i = 0; i < q.rows.length; i++) {
        var item = q.rows.item(i)

        res.push({
            entryId: item.rowid,
            name: item.name,
            entryState: parseInt(item.entryState, 10),
            seq: parseInt(item.seq, 10),
        })
    }

    return res
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

    simpleQuery('UPDATE _projects SET name=?, entryState=? WHERE rowid=?',
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

function loadRecurrings(forProject, targetModel) {
    forProject = defaultFor(forProject, defaultProjectId);
    var q = simpleQuery('\
        SELECT rowid, *
        FROM recurrings
        WHERE project=?
        ORDER BY intervalDays ASC
    ;', [forProject])

    _doProcessEntries(q, targetModel)
}

function addRecurring(startDate, entryState, intervalDays, project, text, description, addForToday) {
    simpleQuery('INSERT INTO recurrings VALUES (?, ?, ?, ?, ?, ?, ?)', [
                    Helpers.getDateString(startDate), (addForToday === true ? todayString : ""),
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
                     createdOn: Helpers.getDate(0, new Date(item.createdOn)),
                     weight: parseInt(item.weight, 10),
                     interval: parseInt(item.interval, 10),
                     project: parseInt(item.project, 10),
                     text: item.text,
                     description: item.description
                 });
    }

    return res;
}

function _doProcessEntries(queryResult, targetModel) {
    if (!!worker) {
        console.time('[storage] processing entries')
        var len = queryResult.rows.length
        var object = []
        for (var i = 0; i < len; ++i) {
            object[i] = queryResult.rows.item(i)
        }
        console.log("[storage] loading", len, "rows")
        console.timeEnd('[storage] processing entries')

        worker.sendMessage({
            'event': 'loadEntries',
            'model': targetModel,
            'queryData': object
        })
    } else {
        error(qsTr("Database unavailable"),
              qsTr("The database worker is not ready."))
        return
    }
}

function loadEntries(forProject, targetModel) {
    forProject = defaultFor(forProject, defaultProjectId);
    var q = simpleQuery('\
        SELECT rowid, *
        FROM entries
        WHERE project=?
            AND date >= ?
        ORDER BY date ASC
    ;', [forProject, todayString])

    _doProcessEntries(q, targetModel)
}

function loadArchive(forProject, targetModel) {
    forProject = defaultFor(forProject, defaultProjectId);
    var q = simpleQuery('\
        SELECT rowid, *
        FROM entries
        WHERE project=?
            AND date < ?
        ORDER BY date DESC
    ;', [forProject, todayString])

    console.log("LOADING ARCHIVE")
    _doProcessEntries(q, targetModel)
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

    // copy all entries with entryState = todo and subState = today, that are older than today
    // (and, if we have fromDate, younger than fromDate), and set the new date to today's date
    var mainResult = simpleQuery('INSERT INTO entries(date, entryState, subState, createdOn, weight, interval, project, text, description)\
        SELECT date("now", "localtime"), entryState, subState, createdOn, weight, interval, project, text, description FROM entries\
            WHERE (date < date("now", "localtime")) AND (entryState = ?) AND (subState = ?) AND (date >= date(?, "localtime")) ORDER BY rowid ASC',
                             [EntryState.todo, EntrySubState.today, fromDateString]);

    var updateResult = simpleQuery('UPDATE entries SET subState=? WHERE\
        (date < date("now", "localtime")) AND (entryState = ?) AND (subState = ?) AND (date >= date(?, "localtime"))',
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
    var whereClause = '(entryState = ?) AND (lastCopiedTo != ? OR lastCopiedTo is null) AND ' +
        '(date(startDate, "localtime") <= date(?, "localtime")) AND ' +
        '((julianday(?, "localtime") - julianday(startDate, "localtime")) % intervalDays = 0)';

    var mainResult = simpleQuery(
        'INSERT INTO entries(date, entryState, subState, createdOn, weight, interval, project, text, description) ' +
            'SELECT ?, 0, 0, ?, 1, intervalDays, project, text, description FROM recurrings WHERE ' + whereClause,
        [todayString, todayString, EntryState.todo, todayString, todayString, todayString]
    );

    var updateResult = 0;
    if (mainResult !== undefined && mainResult.rowsAffected > 0) {
        // only update if something was copied
        updateResult = simpleQuery('UPDATE recurrings SET lastCopiedTo=? WHERE ' + whereClause,
            [todayString, EntryState.todo, todayString, todayString, todayString]
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
