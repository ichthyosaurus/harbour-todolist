/*
 * This file is part of opal-about.
 * Copyright (C) 2020  Mirian Margiani
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * opal-about is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * opal-about is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with opal-about.  If not, see <http://www.gnu.org/licenses/>.
 *
 * *** CHANGELOG: ***
 *
 * 2020-08-23:
 * - initial release
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject {
    property string spdxId
    property var forComponents: []
    property string customShortText: ""

    readonly property bool error: __error
    readonly property string name: __name
    readonly property string fullText: __fullText

    property string __localUrl: "%1/%2.json".arg(StandardPaths.temporary).arg(spdxId)
    property string __remoteUrl: "https://spdx.org/licenses/%1.json".arg(spdxId)
    property string __name: ""
    property string __fullText: ""
    property bool __error: false

    onSpdxIdChanged: _load(true)
    Component.onCompleted: _load()

    function _load(force) {
        if (fullText !== "" && force !== true) return;
        if (spdxId === undefined || spdxId === "") {
            __error = true;
            console.error("cannot load license without spdxId");
            return;
        }

        __name = "";
        __fullText = "";
        __error = false;

        __request("GET", __localUrl, function(xhr) {
            try {
                var o = JSON.parse(xhr.responseText);
                if (!o || typeof o !== "object") throw 1;
                __fullText = o['licenseText'];
                __name = o['name'];
                console.log("license loaded locally from", __localUrl);
            }
            catch (e) {
                _loadRemote();
            }
        }, function(xhr) {
           _loadRemote();
        });
    }

    function _loadRemote() {
        __request("GET", __remoteUrl, function(xhr) {
            try {
                var o = JSON.parse(xhr.responseText);
                if (!o || typeof o !== "object") throw 1;
                __fullText = o['licenseText'];
                __name = o['name'];
                console.log("license loaded remotely from", __remoteUrl);

                __request("PUT", __localUrl, function(x){
                    console.log("saved license with status", x.status, "to", __localUrl);
                }, function(x){}, xhr.responseText);
            }
            catch (e) {
                console.log("failed to load license remotely from", __remoteUrl);
                __error = true;
            }
        }, function(xhr) {
            console.log("failed to load license remotely from", __remoteUrl);
            __error = true;
        });
    }

    function __request(type, url, onSuccess, onFailure, postData) {
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
}
