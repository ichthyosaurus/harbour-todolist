/*
 * This file is part of harbour-treasure-chest.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

.pragma library
.import QtQuick.LocalStorage 2.0 as LS

//
// BEGIN Database configuration
//

var dbName = "MyDatabase"
var dbDescription = ""
var dbSize = 2000000  // 2 MB
var enableAutoMaintenance = true

var dbMigrations = [
    // [1, 'CREATE TABLE IF NOT EXISTS ...;'],
    // [2, function(tx){ tx.executeSql(...); }],

    // add new versions here...
    //
    // remember: versions must be numeric, e.g. 0.1 but not 0.1.1
]

// The database helper provides easy settings handling
// through a key-value store in this table. The table
// name can be changed here initially. The table is
// created automatically when the database is first
// created, before any migrations are run.
//
// Columns: key TEXT UNIQUE, value TEXT
var settingsTable = "__local_settings"


// The database helper will run database maintenance in
// regular intervals if enableAutoMaintenance is set to true.
// By default, this includes only running VACUUM on the
// database. You can assign a custom function here that
// will be executed too.
//
// The function takes no arguments and can use regular
// database functions (simpleQuery, guardedTx, etc.) to
// access the database.
var maintenanceCallback = function() {}


//
// BEGIN Database handling boilerplate
// It is usually not necessary to change this part.
//
// Functions:
// - simpleQuery(query, values): for most queries.
// - readQuery(query, values): for read-only queries.
// - guardedTx(tx, callback): run callback(tx) in a transaction
//                            and roll back on errors.
// - getDatabase(): to get full access to the database.
//
// - defaultFor(arg, val): to use a fallback value 'val' if 'arg' is nullish.
// - getSetting(key, fallback): get a settings value from the settings table.
// - setSetting(key, value): save a settings value to the settings table.
//
// Properties:
// - dbOk: set to false if the database is unavailable due to errors.

var dbOk = true

var __initialized = false
var __db = null

function defaultFor(arg, val) {
    return typeof arg !== 'undefined' ? arg : val
}

function isSameValue(x, y) {
    // Polyfill for Object.is() which is not available in ancient Qt.
    // - https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/is
    // - https://github.com/zloirock/core-js/blob/master/packages/core-js/internals/same-value.js
    // - https://stackoverflow.com/a/48300450
    return x === y ? x !== 0 || 1 / x === 1 / y : x !== x && y !== y;
}

function getDatabase() {
    if (!dbOk) {
        console.error("database is not available, check previous logs")
        throw new Error("database is not available, check previous logs");
    }

    if (!__initialized || __db === null) {
        console.log("initializing database...")
        __db = LS.LocalStorage.openDatabaseSync(
            dbName, "", dbDescription, dbSize);

        if (__doInit(__db)) {
            __initialized = true;
            dbOk = true;

            if (enableAutoMaintenance) {
                __doDatabaseMaintenance();
            }
        } else {
            dbOk = false;
        }
    }

    return __db;
}

function readQuery(query, values) {
    return simpleQuery(query, values, true)
}

function guardedTx(tx, callback) {
    var res = null

    try {
        tx.executeSql('SAVEPOINT __guarded_tx_started__;')
        res = callback(tx)
        tx.executeSql('RELEASE __guarded_tx_started__;')
    } catch (e) {
        tx.executeSql('ROLLBACK TO __guarded_tx_started__;')

        console.error("guarded transaction failed:",
                      "\n   ERROR  >", e,
                      "\n   CALLER >", e.stack);
        throw e
    }

    return res
}

function simpleQuery(query, values, readOnly) {
    // The QtQuick.LocalStorage implementation does not perform rollbacks
    // on failed transactions, contrary to what is stated in the documentation.
    //
    // You can safely use simpleQuery() which handles errors and rollbacks
    // properly. Check the implementation and use guardedTx() in custom transactions.
    //
    // This is the case in Qt 5.6 (Sailfish 4.6) but the code has not changed
    // at least until Qt 6.8. That means manual guarding is necessary: every
    // transaction must be enclosed in a throw/catch block and perform
    // either ROLLBACK or SAVEPOINT <name> with ROLLBACK TO <name> when needed.

    var db = getDatabase();
    var res = {
        ok: false,
        rowsAffected: 0,
        insertId: undefined,
        rows: []
    };

    values = defaultFor(values, []);

    if (!query) {
        console.error("bug: cannot execute an empty database query");
        return res;
    }

    try {
        var callback = function(tx) {
            var rs = null

            if (readOnly === true) {
                // Rollbacks are only possible and sensible
                // in read-write transactions. It is necessary
                // to skip guardedTx() here.
                rs = tx.executeSql(query, values)
            } else {
                rs = guardedTx(tx, function(tx){
                    return tx.executeSql(query, values)
                })
            }

            if (rs.rowsAffected > 0) {
                res.rowsAffected = rs.rowsAffected;
            } else {
                res.rowsAffected = 0;
            }

            res.insertId = rs.insertId;
            res.rows = rs.rows;
        };

        if (readOnly === true) {
            db.readTransaction(callback)
        } else {
            db.transaction(callback)
        }

        res.ok = true;
    } catch(e) {
        console.error((readOnly === true ? "read-only " : "") + "database query failed:",
                      "\n   ERROR  >", e,
                      "\n   QUERY  >", query,
                      "\n   VALUES >", values);
        res.ok = false;
    }

    return res;
}

function setSetting(key, value) {
    simpleQuery('INSERT OR REPLACE INTO %1 VALUES (?, ?);'.arg(settingsTable),
                [key, value]);
}

function getSetting(key, fallback) {
    var res = simpleQuery('SELECT value FROM %1 WHERE key=? LIMIT 1;'.
                            arg(settingsTable),
                          [key]);

    if (res.rows.length > 0) {
        res = defaultFor(res.rows.item(0).value, fallback);
    } else {
        res = fallback;
    }

    return res;
}

function createSettingsTable(tx) {
    // It is usually not necessary to call this function manually.
    // The settings table is created automatically for you when the database is first created.
    //
    // You can use this to migrate from an old settings system to
    // using the internal settings provided by the database helper.

    guardedTx(tx, function(tx){
        tx.executeSql('CREATE TABLE IF NOT EXISTS %1 (key TEXT UNIQUE, value TEXT);'.
                      arg(settingsTable));
    })
}

function makeTableSortable(tx, tableName, orderColumn) {
    // This function sets up a table to automatically update
    // an ordering column. It does so by creating a view on the
    // table with triggers that handle updating the ordering column.
    //
    // Usage:
    //   Manually create a table that has at least one
    //   content column (any type) and one order column (integer).
    //   Then call this function.
    //
    //   After calling this function, the table must not be used
    //   directly anymore, only ever the view that is created by
    //   this function. Example: tableName is "_mytable", view is "mytable".
    //
    //   Note: this function must be called again after modifying
    //   the table schema in migrations.
    //
    // Arguments:
    //   tx: database transaction
    //   tableName: name of the already existing table that should
    //     be managed. It must be a string starting with an underscore ('_').
    //   orderColumn: name of the column that stores the order of
    //     entries. It must be a string. The column must be of type INTEGER.
    //   columns: complete list of table columns, excluding the order column.
    //     It must be an array of strings.
    //
    // Warnings:
    //   1. The parameters are not thoroughly verified before they are
    //      used to build SQL queries. Mistakes can destroy your database.
    //   2. Order values start at 1.
    //   3. Invalid order values (0, <0, >count) will raise an error.
    //      Use NULL as order to insert a row at the end.

    // The implementation is based on
    // https://stackoverflow.com/a/19976918 (LS_dev, CC-BY-SA-3.0).

    if (!(!!tableName) || typeof tableName != "string" || false) {
        throw new Error("Table name must be a string starting with " +
                        "an underscore ('_'), got '%1'".arg(tableName))
    }

    var viewName = tableName.toString().slice(1)

    if (!(!!orderColumn) || typeof orderColumn != "string") {
        throw new Error("Order column must be a string, got '%1'".arg(orderColumn))
    }

    var columns = []
    var rs = tx.executeSql('SELECT name FROM pragma_table_info("%1") as info;'.arg(tableName))

    for (var i = 0; i < rs.rows.length; ++i) {
        var name = rs.rows.item(i).name.toString()

        if (name !== orderColumn) {
            columns.push(name)
        }
    }

    if (columns.length === 0) {
        throw new Error("Table '%1' must have at least one column " +
                        "other than the order column".arg(tableName))
    }

    var columnsString = columns.join(', ')
    var newColumnsString = 'NEW.' + columns.join(', NEW.')

    // Table view, which will handle all inserts, updates and deletes
    tx.executeSql('\
        CREATE VIEW %1 AS SELECT * FROM %2;
    '.arg(viewName).arg(tableName))

    // Triggers:
    // Raise error when inserting invalid index (out of bounds or non integer)
    tx.executeSql('\
        CREATE TRIGGER %1_ins_err INSTEAD OF INSERT ON %1
        WHEN NEW.%3 < 1 OR NEW.%3 > (SELECT COUNT()+1 FROM %2) OR CAST(NEW.%3 AS INT) <> NEW.%3
        BEGIN
            SELECT RAISE(ABORT, "Invalid index!");
        END;
    '.arg(viewName).arg(tableName).arg(orderColumn))

    // Increments all indexes when new row inserted in middle of table
    //
    // not possible:   INSERT INTO %2 SELECT * FROM NEW;
    // https://sqlite.org/forum/info/320a27de1cfb0dfb
    tx.executeSql('\
        CREATE TRIGGER %1_ins INSTEAD OF INSERT ON %1
        WHEN NEW.%3 BETWEEN 1 AND (SELECT COUNT() FROM %2)+1
        BEGIN
            UPDATE %2 SET %3 = %3 + 1 WHERE %3 >= NEW.%3;
            INSERT INTO %2(%4, %3) VALUES(%5, NEW.%3);
        END;
    '.arg(viewName).arg(tableName).arg(orderColumn).arg(columnsString).arg(newColumnsString))

    // Insert row in last when supplied index is NULL
    tx.executeSql('\
        CREATE TRIGGER %1_ins_last INSTEAD OF INSERT ON %1
        WHEN NEW.%3 IS NULL
        BEGIN
            INSERT INTO %2(%4, %3) VALUES(%5, (SELECT COUNT()+1 FROM %2));
        END;
    '.arg(viewName).arg(tableName).arg(orderColumn).arg(columnsString).arg(newColumnsString))

    // Decrements indexes when item is removed
    tx.executeSql('\
        CREATE TRIGGER %1_del INSTEAD OF DELETE ON %1
        BEGIN
            DELETE FROM %2 WHERE %3 = OLD.%3;
            UPDATE %2 SET %3 = %3 - 1 WHERE %3>OLD.%3;
        END;
    '.arg(viewName).arg(tableName).arg(orderColumn))

    // Raise error when updating to invalid index
    tx.executeSql('\
        CREATE TRIGGER %1_upd_err INSTEAD OF UPDATE OF %3 ON %1
        WHEN NEW.%3 NOT BETWEEN 1 AND (SELECT COUNT() FROM %2) OR CAST(NEW.%3 AS INT)<>NEW.%3 OR NEW.%3 IS NULL
        BEGIN
            SELECT RAISE(ABORT, "Invalid index!");
        END;
    '.arg(viewName).arg(tableName).arg(orderColumn))

    // Decrements indexes when item is moved up
    tx.executeSql('\
        CREATE TRIGGER %1_upd_up INSTEAD OF UPDATE OF %3 ON %1
        WHEN NEW.%3 BETWEEN OLD.%3+1 AND (SELECT COUNT() FROM %2)
        BEGIN
            UPDATE %2 SET %3 = NULL WHERE %3 = OLD.%3;
            UPDATE %2 SET %3 = %3 - 1 WHERE %3 BETWEEN OLD.%3 AND NEW.%3;
            UPDATE %2 SET %3 = NEW.%3 WHERE %3 IS NULL;
        END;
    '.arg(viewName).arg(tableName).arg(orderColumn))

    // Increments indexes when item is moved down
    tx.executeSql('\
        CREATE TRIGGER %1_upd_down INSTEAD OF UPDATE OF %3 ON %1
        WHEN NEW.%3 BETWEEN 1 AND OLD.%3-1
        BEGIN
            UPDATE %2 SET %3 = NULL WHERE %3 = OLD.%3;
            UPDATE %2 SET %3 = %3 + 1  WHERE %3 BETWEEN NEW.%3 AND OLD.%3;
            UPDATE %2 SET %3 = NEW.%3 WHERE %3 IS NULL;
        END;
    '.arg(viewName).arg(tableName).arg(orderColumn))
}

function __doInit(db) {
    // Due to https://bugreports.qt.io/browse/QTBUG-71838 which was fixed only
    // in Qt 5.13, it's not possible the get the actually current version number
    // from the database object after a migration. The db.version field always
    // stays at the initial version. Instead of reopening the database and
    // replacing the db object, we track the current version manually when
    // applying migrations (previousVersion).
    //
    // However, db.changeVersion(from, to) expects the same version as stored in
    // the database object as "from" parameter. This means that calls to
    // changeVersion must use db.version as the first argument and not the correct
    // version number. When a migration fails, it is important to roll back to
    // the version the database is actually on, i.e. the manually tracked version.
    // That means a last call to changeVersion(db.version, previousVersion) is
    // necessary.
    //
    // Furthermore, QtQuick.LocalStorage does not perform rollbacks
    // on failed transactions, contrary to what is stated in the documentation.
    // See the docs on simpleQuery() for details.

    var latestVersion = dbMigrations[dbMigrations.length-1][0]

    var initialVersion = db.version
    var previousVersion = Number(initialVersion)
    var nextVersion = null

    if (initialVersion === "") {
        console.log("initializing a new database...")
        db.transaction(createSettingsTable);
    }

    if (initialVersion !== String(latestVersion)) {
        for (var i in dbMigrations) {
            nextVersion = dbMigrations[i][0]

            if (previousVersion < nextVersion) {
                try {
                    console.log("migrating database to version", nextVersion)

                    db.changeVersion(db.version, nextVersion, function(tx){
                        guardedTx(tx, function(tx){
                            var migrationType = typeof dbMigrations[i][1]
                            if (migrationType === "string") {
                                tx.executeSql(dbMigrations[i][1])
                            } else if (migrationType === "function") {
                                dbMigrations[i][1](tx)
                            } else {
                                throw new Error("expected migration as string or function, got " +
                                                migrationType + " instead")
                            }
                        })
                    })
                } catch (e) {
                    console.error("fatal: failed to upgrade database version from",
                                  previousVersion, "to", nextVersion)
                    console.error("exception:\n", e)
                    db.changeVersion(db.version, previousVersion, function(tx){})
                    break
                }

                previousVersion = nextVersion
            }
        }
    }

    if (previousVersion !== latestVersion) {
        console.error("fatal: expected database version",
                      String(latestVersion),
                      "but loaded database has version", previousVersion)
        return false
    }

    console.log("loaded database version", previousVersion)

    return true
}

function __vacuumDatabase() {
    var db = getDatabase();

    try {
        db.transaction(function(tx) {
            // VACUUM cannot be executed inside a transaction, but the LocalStorage
            // module cannot execute queries without one. Thus we have to manually
            // end the transaction from inside the transaction...
            var rs = tx.executeSql("END TRANSACTION;");
            var rs2 = tx.executeSql("VACUUM;");
        });
    } catch(e) {
        console.error("database vacuuming failed:\n", e);
    }
}

function __doDatabaseMaintenance() {
    var last_maintenance = simpleQuery(
        'SELECT * FROM %1 WHERE key = "last_maintenance" \
             AND value >= date("now", "-60 day") LIMIT 1;'.
                arg(settingsTable),
        [], true);

    if (last_maintenance.rows.length > 0) {
        return;
    }

    console.log("running regular database maintenance...")

    if (maintenanceCallback instanceof Function) {
        try {
            maintenanceCallback()
        } catch(e) {
            console.error("database maintenance failed:",
                          "\n   ERROR  >", e,
                          "\n   STACK  >\n", e.stack);
        }
    }

    __vacuumDatabase();
    console.log("maintenance finished")
    setSetting("last_maintenance", new Date().toISOString());
}
