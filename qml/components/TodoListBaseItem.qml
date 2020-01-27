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
import "../constants" 1.0

ListItem {
    id: item
    width: ListView.view.width
    contentHeight: row.height +
                   (isEditing ? editButtonRow.height : 0) +
                   (intervalCombo.visible ? intervalCombo.height : 0) +
                   (startDateButton.visible ? startDateButton.height : 0)
    ListView.onRemove: animateRemoval(item) // enable animated list item removals

    property string title: ""
    property string description: ""
    property string extraDeleteWarning: ""
    property bool infoMarkerEnabled: false
    property bool editable: true
    property bool deletable: true
    property bool descriptionEnabled: true
    property bool customClickHandlingEnabled: false

    property bool alwaysShowInterval: false
    property bool editableInterval: false
    property string intervalProperty: "interval"
    property string intervalStartProperty: "date"

    property bool isEditing: false
    signal markItemAs(var which, var mainState, var subState)
    signal copyAndMarkItem(var which, var mainState, var subState, var copyToDate)
    signal saveItemTexts(var which, var newText, var newDescription)
    signal saveItemRecurring(var which, var interval, var startDate)
    signal deleteThisItem(var which)

    function startEditing() {
        isEditing = true;
        item.enabled = false;
        editDescriptionField.text = description;
        editTextField.text = title;
        editTextField.forceActiveFocus();
    }

    function saveEdited() {
        var newText = editTextField.text;
        var newDescription = editDescriptionField.text;
        if (newText === "") return;
        saveItemTexts(index, newText.trim(), newDescription.trim());
        if (editableInterval) saveItemRecurring(index, intervalCombo.currentItem.value, startDateButton.startDate);
        stopEditing();
    }

    function stopEditing() {
        isEditing = false;
        item.enabled = true;
    }

    showMenuOnPressAndHold: customClickHandlingEnabled ? undefined : false
    Connections {
        target: customClickHandlingEnabled ? null : item
        onPressAndHold: if (editable) startEditing();
        onClicked: menu ? openMenu() : {}
    }

    Row {
        id: row
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            topMargin: Theme.paddingMedium
            bottomMargin: Theme.paddingMedium
        }
        height: Math.max(textColumn.height, statusIcon.height+2*Theme.paddingMedium)
        spacing: Theme.paddingMedium

        HighlightImage {
            id: statusIcon
            opacity: Theme.opacityHigh
            visible: !isEditing
            highlighted: item.highlighted
            width: Theme.iconSizeSmallPlus
            height: width
            color: Theme.primaryColor
            anchors.top: parent.top
            anchors.topMargin: parent.anchors.topMargin
        }

        IconButton {
            id: deleteButton
            visible: isEditing
            enabled: deletable
            width: statusIcon.width; height: statusIcon.height
            anchors.top: statusIcon.top
            icon.source: "image://theme/icon-m-delete"
            onClicked: {
                var dialog = pageStack.push(Qt.resolvedUrl("../pages/ConfirmDeleteDialog.qml"), {
                                                text: title,
                                                description: description,
                                                warning: extraDeleteWarning
                                            })
                dialog.accepted.connect(function() {
                    deleteThisItem(index)
                });
            }
        }

        Column {
            id: textColumn
            anchors.top: parent.top
            width: parent.width-statusIcon.width-spacing

            Spacer { height: Theme.paddingMedium }

            Row {
                width: parent.width//-Theme.horizontalPageMargin

                Label {
                    visible: !isEditing
                    width: parent.width-intervalLabel.width-hasInfoLabel.width
                    text: title
                    font.pixelSize: Theme.fontSizeMedium
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    elide: Text.ElideNone
                }

                TextField {
                    id: editTextField
                    visible: isEditing
                    z: row.z-1
                    placeholderText: title
                    text: title
                    labelVisible: false
                    textTopMargin: 0
                    textMargin: 0
                    width: parent.width

                    EnterKey.enabled: title.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-" + (descriptionEnabled ? "next" : "accept")
                    EnterKey.onClicked: {
                        if (descriptionEnabled) {
                            editDescriptionField.forceActiveFocus();
                        } else {
                            focus = false;
                            saveEdited();
                        }
                    }
                }

                Label {
                    id: hasInfoLabel
                    horizontalAlignment: Text.AlignRight
                    visible: !isEditing && infoMarkerEnabled
                    width: visible ? Theme.iconSizeExtraSmall : 0
                    text: "⭑"
                    color: Theme.highlightColor
                    opacity: Theme.opacityHigh
                }

                Label {
                    id: intervalLabel
                    visible: !isEditing && (alwaysShowInterval || model[intervalProperty] > 0)
                    text: model[intervalProperty] !== undefined ? model[intervalProperty] : ""
                    color: Theme.highlightColor
                    opacity: Theme.opacityHigh
                    width: visible ? implicitWidth : 0

                    Rectangle {
                        visible: parent.visible
                        anchors.centerIn: parent
                        width: parent.width+Theme.paddingSmall; height: parent.height
                        radius: 20
                        color: Theme.rgba(Theme.highlightColor, Theme.opacityLow)
                    }
                }
            }

            Label {
                visible: descriptionEnabled && description !== "" && !isEditing
                opacity: Theme.opacityHigh
                width: parent.width
                text: description
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
            }

            TextArea {
                id: editDescriptionField
                visible: isEditing && descriptionEnabled
                z: row.z-1
                placeholderText: description !== "" ? description : qsTr("Description (optional)")
                text: description
                labelVisible: false
                textTopMargin: 0
                textMargin: 0
                width: parent.width

                // This element causes for some reason the following error:
                // unknown:296 - file:///usr/lib/qt5/qml/Sailfish/Silica/private/TextBase.qml:296:5:
                //      QML Label: Binding loop detected for property "_elideText"
                // We can 'fix' this by declaring the placeholder text's elide mode
                // manually. We specify Text.ElideNone, which somehow means that
                // the label decides automatically to which side it elides anyways
                // (which is what we want).
                _placeholderTextLabel.elide: Text.ElideNone
            }

            Spacer { height: Theme.paddingMedium }
        }
    }

    Column {
        id: intervalEditColumn
        visible: isEditing
        anchors.top: row.bottom
        height: childrenRect.height; width: parent.width

        IntervalCombo {
            id: intervalCombo
            currentIndex: model[intervalProperty]
            enabled: editableInterval
            visible: parent.visible && (model[intervalProperty] > 0 || alwaysShowInterval)
            height: visible ? Theme.itemSizeSmall : 0
        }

        StartDateButton {
            id: startDateButton
            startDate: model[intervalStartProperty] !== undefined ? model[intervalStartProperty] : new Date()
            enabled: intervalCombo.currentIndex !== 0
            visible: parent.visible && editableInterval
            height: visible ? Theme.itemSizeSmall : 0
        }
    }

    Row {
        id: editButtonRow
        visible: isEditing
        anchors.top: intervalEditColumn.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge

        Button {
            text: qsTr("Cancel")
            onClicked: stopEditing();
        }

        Button {
            text: qsTr("Save")
            onClicked: saveEdited();
        }
    }

    states: [
        State {
            name: "todo"
            when: entryState === EntryState.todo
            PropertyChanges { target: statusIcon; source: "../images/icon-todo.png"; opacity: Theme.opacityHigh }
        },
        State {
            name: "ignored"
            when: entryState === EntryState.ignored
            PropertyChanges { target: statusIcon; source: "../images/icon-ignored.png"; }
            PropertyChanges { target: row; opacity: Theme.opacityHigh }
        },
        State {
            name: "done"
            when: entryState === EntryState.done
            PropertyChanges { target: statusIcon; source: "../images/icon-done.png"; }
            PropertyChanges { target: row; opacity: Theme.opacityLow }
        }
    ]
}
