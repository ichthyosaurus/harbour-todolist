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
import "../js/helpers.js" as Helpers

TodoListBaseItem {
    id: item
    descriptionEnabled: true
    infoMarkerEnabled: (createdOn.getTime() !== date.getTime() || subState === EntrySubState.tomorrow)
    title: model.text
    description: model.description

    property bool isArchived: date.getTime() < today.getTime()
    editable: !isArchived

    menu: Component {
        ContextMenu {
            property bool isToday: date.getTime() === today.getTime()
            property bool isSomeday: date.getTime() === someday.getTime()

            MenuItem {
                visible: isArchived && (   entryState !== EntryState.todo
                                        || date.getTime() > main.configuration.lastCarriedOverFrom.getTime())
                text: qsTr("continue today")
                onClicked: copyAndMarkItem(index, entryState, EntrySubState.tomorrow, today);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && entryState !== EntryState.done
                text: qsTr("done")
                onClicked: markItemAs(index, EntryState.done, subState);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && isToday
                         && entryState !== EntryState.done
                         && subState !== EntrySubState.tomorrow
                text: qsTr("done for today, continue tomorrow")
                onClicked: copyAndMarkItem(index, EntryState.done, EntrySubState.tomorrow, Helpers.getDate(1, date));
            }
            MenuItem {
                visible:    editable && !isArchived
                         && !isSomeday
                         && (entryState === EntryState.todo || entryState === EntryState.ignored)
                         && subState !== EntrySubState.tomorrow
                text: isToday ? qsTr("move to tomorrow") : qsTr("move to next day")
                onClicked: copyAndMarkItem(index, EntryState.ignored, EntrySubState.tomorrow, Helpers.getDate(1, date));
            }
            MenuItem {
                visible:    editable && !isArchived
                         && date.getTime() > today.getTime()
                         && !isSomeday
                         && (entryState === EntryState.todo || entryState === EntryState.ignored)
                         && subState !== EntrySubState.tomorrow
                text: qsTr("move to someday later")
                onClicked: copyAndMarkItem(index, EntryState.ignored, EntrySubState.someday, someday);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && entryState === EntryState.todo
                text: qsTr("ignore")
                onClicked: markItemAs(index, EntryState.ignored, subState);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && !isSomeday
                         && entryState === EntryState.done
                         && subState !== EntrySubState.tomorrow
                text: isToday ? qsTr("continue tomorrow") : qsTr("continue next day")
                onClicked: copyAndMarkItem(index, EntryState.done, EntrySubState.tomorrow, Helpers.getDate(1, date));
            }
            MenuItem {
                visible:    editable && !isArchived
                         && entryState === EntryState.done
                text: qsTr("not completely done yet")
                onClicked: markItemAs(index, EntryState.todo, subState);
            }
            MenuItem {
                enabled: false
                visible: editable || infoMarkerEnabled
                text: {
                    var text = "";

                    if (infoMarkerEnabled) {
                        text = qsTr("⭑ %1, %2")

                        if (createdOn.getTime() === date.getTime()) {
                            text = text.arg(isToday ? qsTr("from today") : qsTr("from this day"));
                        } else if (createdOn.getTime() === Helpers.getDate(-1, date).getTime()) {
                            text = text.arg(isToday ? qsTr("from yesterday") : qsTr("from last day"));
                        } else if (createdOn.getTime() === Helpers.getDate(-1, today).getTime()) {
                            text = text.arg(qsTr("from yesterday"));
                        } else {
                            text = text.arg(qsTr("from earlier"));
                        }

                        if (entryState === EntryState.todo) {
                            if (subState === EntrySubState.today) {
                                if (!isSomeday) text = text.arg(isToday ? qsTr("for today") : qsTr("for this day"))
                                else text = text.arg(qsTr("for someday later"))
                            } else text = text.arg(qsTr("carried over"))
                        } else if (entryState === EntryState.ignored) {
                            if (subState === EntrySubState.today) text = text.arg(isToday ? qsTr("ignored today") : qsTr("ignored this day"))
                            else if (subState === EntrySubState.tomorrow) text = text.arg(isToday ? qsTr("to be done tomorrow") : qsTr("to be done next day"))
                            else if (subState === EntrySubState.someday) text = text.arg(qsTr("to be done someday later"))
                        } else if (entryState === EntryState.done) {
                            if (subState === EntrySubState.today) text = text.arg(isToday ? qsTr("done today") : qsTr("done this day"))
                            else if (subState === EntrySubState.tomorrow) text = text.arg(isToday ? qsTr("continue tomorrow") : qsTr("continue next day"))
                            else if (subState === EntrySubState.someday) text = text.arg(qsTr("to be done someday later"))
                        }

                        if (editable) text += "\n"
                    }

                    if (editable) text += qsTr("press and hold to edit or delete")
                    return text;
                }
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                _elideText: false
                _fadeText: true
            }
        }
    }
}
