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

.pragma library
.import QtQuick.LocalStorage 2.0 as LS


function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

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
    // entries: ID, date, state, substate, createdOn, weight, interval, category, text, description

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS entries(\
            date STRING NOT NULL,
            state STRING NOT NULL,
            substate STRING NOT NULL,
            createdOn STRING NOT NULL,
            weight INTEGER NOT NULL,
            interval INTEGER NOT NULL,
            category STRING NOT NULL,
            text TEXT NOT NULL,
            description TEXT
        );');
    });
}

function simpleQuery(query, values/*, getSelectedCount*/) {
    var db = getDatabase();
    var res = undefined;
    values = defaultFor(values, []);

    if (!query) {
        console.log("error: empty query");
        return undefined;
    }

    try {
        db.transaction(function(tx) { res = tx.executeSql(query, values); });
    } catch(e) {
        console.log("error in query: '"+ e +"', values=", values);
        res = undefined;
    }

    return res;
}

function getEntries() {
    var q = simpleQuery('SELECT rowid, * FROM entries;', []);
    var res = []

    for (var i = 0; i < q.rows.length; i++) {
        var item = q.rows.item(i);

        res.push({entryid: item.rowid,
                     date: new Date(item.date),
                     entrystate: parseInt(item.state, 10),
                     substate: parseInt(item.substate, 10),
                     createdOn: new Date(item.createdOn),
                     weight: parseInt(item.weight, 10),
                     interval: parseInt(item.interval, 10),
                     category: item.category,
                     text: item.text,
                     description: item.description
                 });
    }

    return res;
}

function addEntry(date, entrystate, substate, createdOn, weight, interval, category, text, description) {
    simpleQuery('INSERT INTO entries VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', [
        date.toLocaleString(Qt.locale(), "yyyy-MM-dd"),
        Number(entrystate), Number(substate),
        createdOn.toLocaleString(Qt.locale(), "yyyy-MM-dd"),
        weight, interval, category, text, description
    ])

    var q = simpleQuery('SELECT rowid FROM entries ORDER BY rowid DESC LIMIT 1;', []);
    if (q.rows.length > 0) return q.rows.item(0).rowid;
    else return undefined;
}

function updateEntry(entryid, date, entrystate, substate, createdOn, weight, interval, category, text, description) {
    if (entryid === undefined) {
        console.warn("failed to update: invalid entry id", date, text);
        return;
    }

    simpleQuery('UPDATE entries SET\
        date=?, state=?, substate=?,
        createdOn=?, weight=?, interval=?,
        category=?, text=?, description=? WHERE rowid=?', [
        date.toLocaleString(Qt.locale(), "yyyy-MM-dd"),
        Number(entrystate), Number(substate),
        createdOn.toLocaleString(Qt.locale(), "yyyy-MM-dd"),
        weight, interval, category, text, description,
        entryid
    ])
}

function deleteEntry(entryid) {
    if (entryid === undefined) {
        console.warn("failed to delete: invalid entry id");
        return;
    }

    simpleQuery('DELETE FROM entries WHERE rowid=?', [entryid]);
}
