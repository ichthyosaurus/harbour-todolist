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
    // entries: ID, date, state, substate, parent, weight, text, description
    // settings: SETTING, value

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS entries(\
            id INTEGER NOT NULL, date STRING NOT NULL, state STRING NOT NULL,\
            substate STRING NOT NULL, parent INTEGER, weight INTEGER NOT NULL,\
            text TEXT NOT NULL, description TEXT,\
            PRIMARY KEY(id)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT NOT NULL PRIMARY KEY, value TEXT)');
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

function getSetting(key) {
    var value = simpleQuery('SELECT * FROM settings WHERE setting=? LIMIT 1;', [key]);

    if (rs.rows.length > 0) {
        return res.rows.item(0);
    } else {
        return undefined;
    }
}

function setSetting(key, value) {
    simpleQuery('INSERT OR REPLACE INTO settings VALUES (?, ?);', [key, value]);
}
