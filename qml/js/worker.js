/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// We track the calls to the worker here to make sure
// that items don't get loaded into the wrong model.
// Qt seems to queue the signals in both directions so that
// they should never cross but it's better to be safe than sorry.
//
// This counter keeps track of the current serial number.
// It must not be used directly. Use the serial number
// that is passed through for checks.
var lastSeries = 0

// Important: it appears that even though it should be possible,
// ListModel objects passed into the worker script don't work.
// Entries added in the worker don't appear outside of the worker.
// It is also not possible to pass a LocalStorage SQL query result
// object into the worker for post-processing.
//
// That means:
// - All messages must contain a "model" field that holds a ID string
//   for the affected model. The actual changes to the model happen outside.
// - All query results must be converted into JS objects before they
//   are passed into the worker.
//
// The performance gain for large models is still quite ok.
// At least the app doesn't freeze as much as when all processing
// is done in the main thread.

WorkerScript.onMessage = function(message) {
    if (message.event === 'loadEntries') {
        var currentSeries = lastSeries + 1
        lastSeries = currentSeries

        console.time('[worker] loading series %1'.arg(currentSeries))
        _generateEntries(message.queryData, message.model, currentSeries)
        console.timeEnd('[worker] loading series %1'.arg(currentSeries))
    } else {
        console.error('[worker] cannot handle unknown message:',
                      JSON.stringify(message))
        WorkerScript.sendMessage({
            'event': 'error',
            'notice': 'unknown message received',
            'data': JSON.stringify(message)
        })
    }
}

function _getDate(offset, baseDate) {
    var currentDate = baseDate === undefined ? new Date() : baseDate
    currentDate.setDate(currentDate.getDate() + offset)
    currentDate.setHours(0, 0, 0, 0)

    return currentDate
}

function _generateEntries(rawEntries, model, series) {
    WorkerScript.sendMessage({
        'event': 'loadingEntriesStarted',
        'model': model,
        'count': rawEntries.length,
        'series': series,
    })

    var res = []
    var batchSize = 50
    var converter = _convertRegularEntry

    if (model === 'recurrings') {
        converter = _convertRecurringEntry
    }

    for (var i in rawEntries) {
        var item = rawEntries[i]
        res.push(converter(item))

        if (i % batchSize == 0) {
            WorkerScript.sendMessage({
                'event': 'loadingEntriesBatch',
                'entries': res,
                'model': model,
                'series': series,
            })

            res = []
        }
    }

    if (res.length > 0) {
        WorkerScript.sendMessage({
            'event': 'loadingEntriesBatch',
            'entries': res,
            'model': model,
            'series': series,
        })
    }

    WorkerScript.sendMessage({
        'event': 'loadingEntriesFinished',
        'model': model,
        'count': rawEntries.length,
        'series': series,
    })
}

function _convertRegularEntry(item) {
    return {
        entryId: item.rowid,
        date: _getDate(0, new Date(item.date)),
        dateString: item.date,
        entryState: parseInt(item.entryState, 10),
        subState: parseInt(item.subState, 10),
        createdOn: _getDate(0, new Date(item.createdOn)),
        weight: parseInt(item.weight, 10),
        interval: parseInt(item.interval, 10),
        project: parseInt(item.project, 10),
        text: item.text || '',
        description: item.description || '',
    }
}

function _convertRecurringEntry(item) {
    return {
        entryId: item.rowid,
        startDate: new Date(item.startDate),
        entryState: parseInt(item.entryState, 10),
        intervalDays: parseInt(item.intervalDays, 10),
        project: parseInt(item.project, 10),
        text: item.text,
        description: item.description
    }
}
