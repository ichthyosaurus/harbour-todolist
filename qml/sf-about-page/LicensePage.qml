/*
 * This file is part of sf-about-page.
 * Copyright (C) 2020  Mirian Margiani
 *
 * sf-about-page is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sf-about-page is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with sf-about-page.  If not, see <http://www.gnu.org/licenses/>.
 *
 * *** CHANGELOG: ***
 *
 * 2020-04-25:
 * - remove version numbers, use changelog instead
 * - backwards-incompatible changes are marked with "[breaking]"
 *
 * 2020-04-17:
 * - initial release
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

/*
 * This page is automatically made available through AboutPage.qml.
 *
 * You don't have to configure this file. It will load the Rich Text
 * formatted license text from the file 'license.html'. The example
 * license included in the sf-about-page repository is the GNU GPL v3.
 * You can simply replace the 'license.html' file to use a different license.
 *
 */
Page {
    readonly property string licenseFile: "license.html"
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin
        VerticalScrollDecorator { }

        Column {
            id: column
            width: parent.width
            PageHeader { title: qsTr("License") }

            Label {
                anchors {
                    left: parent.left; leftMargin: Theme.horizontalPageMargin
                    right: parent.right; rightMargin: Theme.horizontalPageMargin
                }

                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                textFormat: Text.RichText
                color: Theme.primaryColor
                text: licenseText.text
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }

    QtObject {
        id: licenseText
        property string text: ""
        Component.onCompleted: loadText();

        function loadText() {
            if (text !== "") return text;

            var xhr = new XMLHttpRequest;
            xhr.open("GET", licenseFile);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var response = xhr.responseText;
                    text = '<style type="text/css">A { color: "#ffffff"; }</style>' + response
                }
            };
            xhr.send();
        }
    }
}
