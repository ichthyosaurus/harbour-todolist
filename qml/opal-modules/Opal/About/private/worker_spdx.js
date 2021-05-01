/*
 * This file is part of opal-about.
 * SPDX-FileCopyrightText: 2021 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

var LOG_SCOPE = '[Opal.About]'

function sendError(spdxId) {
    WorkerScript.sendMessage({
        spdxId: spdxId,
        name: "",
        fullText: "",
        error: true
    });
}

function sendSuccess(spdxId, name, fullText) {
    WorkerScript.sendMessage({
        spdxId: spdxId,
        name: name,
        fullText: fullText,
        error: false
    });
}

function request(type, url, onSuccess, onFailure, postData) {
    var xhr = new XMLHttpRequest;
    xhr.open(type, url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            var response = xhr.responseText;

            if (response === "") {
                onFailure(xhr);
            } else {
                onSuccess(xhr);
            }
        }
    };

    if (postData !== undefined && type === "PUT") {
        xhr.send(postData);
    } else {
        xhr.send();
    }
}

function loadRemote(spdxId, localUrl, remoteUrl) {
    request("GET", remoteUrl, function(xhr) {
        try {
            var o = JSON.parse(xhr.responseText);
            if (!o || typeof o !== "object") throw 1;
            console.log(LOG_SCOPE, "license loaded remotely from", remoteUrl);
            sendSuccess(spdxId, o['name'], o['licenseText']);

            request("PUT", localUrl, function(x){
                console.log(LOG_SCOPE, "saved license with status", x.status, "to", localUrl);
            }, function(x){}, xhr.responseText);
        }
        catch (e) {
            console.log(LOG_SCOPE, "failed to load license remotely from", remoteUrl);
            sendError(spdxId);
        }
    }, function(xhr) {
        console.log(LOG_SCOPE, "failed to load license remotely from", remoteUrl);
        sendError(spdxId);
    });
}

WorkerScript.onMessage = function(message) {
    if (message.spdxId === undefined || message.spdxId === "") {
        error = true;
        console.error(LOG_SCOPE, "cannot load license without spdx id");
        sendError("");
        return;
    }

    request("GET", message.localUrl, function(xhr) {
        try {
            var o = JSON.parse(xhr.responseText);
            if (!o || typeof o !== "object") throw 1;
            console.log(LOG_SCOPE, "license loaded locally from", message.localUrl);
            sendSuccess(message.spdxId, o['name'], o['licenseText']);
        }
        catch (e) {
            loadRemote(message.spdxId, message.localUrl, message.remoteUrl);
        }
    }, function(xhr) {
        loadRemote(message.spdxId, message.localUrl, message.remoteUrl);
    });
}
