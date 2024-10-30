/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.Delegates 1.0
import "../constants" 1.0

TwoLineDelegate {
    id: root

    // required properties:
    // - text
    // - description
    //
    // optional:
    // - dragHandler

    property int project: currentProjectId
    property string extraDeleteWarning: ""
    property bool infoMarkerEnabled: false
    property bool editable: true
    property bool deletable: true
    property bool descriptionEnabled: true
    property bool customClickHandlingEnabled: false

    property bool editableShowProject: true

    property bool alwaysShowInterval: false
    property bool editableInterval: false
    property string intervalProperty: "interval"
    property string intervalStartProperty: "date"

    property bool _isArchivedEntry: typeof(_isOld) !== 'undefined' && !!_isOld
    property real _contentOpacity: {
        if (_isArchivedEntry) {
            if (entryState === EntryState.Todo) {
                0.5
            } else if (entryState === EntryState.Ignored) {
                0.6
            } else if (entryState === EntryState.Done) {
                1.0
            }
        } else {
            if (entryState === EntryState.Todo) {
                1.0
            } else if (entryState === EntryState.Ignored) {
                0.6
            } else if (entryState === EntryState.Done) {
                0.5
            }
        }
    }

    signal markItemAs(var which, var mainState, var subState)
    signal copyAndMarkItem(var which, var mainState, var subState, var copyToDate)
    signal moveAndMarkItem(var which, var mainState, var subState, var moveToDate)
    signal saveItemDetails(var which, var newText, var newDescription, var newProject)
    signal saveItemRecurring(var which, var interval, var startDate)
    signal deleteThisItem(var which)

    signal checkboxClicked(var mouse)

    function startEditing() {
        var dialog = pageStack.push(Qt.resolvedUrl("../pages/EditItemDialog.qml"), {
            text: root.text, description: description, descriptionEnabled: descriptionEnabled,
            showRecurring: model[intervalProperty] !== undefined,
            editableRecurring: editableInterval,
            recurringStartDate: model[intervalStartProperty] !== undefined ? model[intervalStartProperty] : new Date(NaN),
            recurringInitialIntervalDays: model[intervalProperty] !== undefined ? model[intervalProperty] : 0,
            extraDeleteWarning: extraDeleteWarning,
            showProject: editableShowProject, project: project
        });
        dialog.accepted.connect(function() {
            if (dialog.requestDeletion) {
                deleteThisItem(index);
            } else {
                saveItemDetails(index, dialog.text.trim(), dialog.description.trim(), dialog.project);
                if (editableInterval) saveItemRecurring(index, dialog.recurringIntervalDays, dialog.recurringStartDate);
            }
        });
    }

    textLabel {
        opacity: _contentOpacity
        wrapped: true
    }
    descriptionLabel {
        opacity: _contentOpacity
        wrapped: true
    }

    minContentHeight: Theme.iconSizeMedium
    padding.topBottom: Theme.paddingSmall
    leftItemAlignment: descriptionLabel.lineCount > 1 ||
                       textLabel.lineCount > 1 ?
                           Qt.AlignTop : Qt.AlignVCenter
    rightItemAlignment: leftItemAlignment

    leftItem: DelegateIconButton {
        id: checkbox

        Binding on highlighted {
            when: root.highlighted
            value: true
        }

        opacity: 0.7 * root._contentOpacity
        iconSize: Theme.iconSizeMedium
        iconSource: {
            if (entryState === EntryState.Todo) {
                Qt.resolvedUrl("../images/icon-m-todo.png")
            } else if (entryState === EntryState.Ignored) {
                Qt.resolvedUrl("../images/icon-m-ignored.png")
            } else if (entryState === EntryState.Done) {
                Qt.resolvedUrl("../images/icon-m-done.png")
            }
        }

        onClicked: {
            if (root.customClickHandlingEnabled) {
                root.checkboxClicked(mouse)
            } else {
                root.openMenu()
            }
        }
    }

    rightItem: Row {
        spacing: 2*Theme.paddingSmall

        OptionalLabel {
            text: infoMarkerEnabled ? "⭑" : ""
            font.pixelSize: Theme.fontSizeSmall
            opacity: Theme.opacityLow
            palette {
                primaryColor: Theme.secondaryHighlightColor
                highlightColor: Theme.highlightColor
            }
        }

        OptionalLabel {
            text: (alwaysShowInterval || model[intervalProperty] > 0) ?
                      model[intervalProperty] : ""
            font.pixelSize: Theme.fontSizeSmall
            palette {
                primaryColor: Theme.secondaryHighlightColor
                highlightColor: Theme.highlightColor
            }

            Rectangle {
                visible: parent.visible
                anchors.centerIn: parent
                width: parent.width + 2*Theme.paddingSmall
                height: parent.height
                radius: 15
                color: Theme.rgba(parent.color,
                                  Theme.opacityFaint)
            }
        }
    }

    showMenuOnPressAndHold: customClickHandlingEnabled ? undefined : false

    Connections {
        target: customClickHandlingEnabled ? null : root
        onPressAndHold: if (editable) startEditing()
        onClicked: menu ? openMenu() : {}
    }
}
