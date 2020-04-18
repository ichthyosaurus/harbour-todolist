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
    infoMarkerEnabled: (createdOn.getTime() !== date.getTime() || subState !== EntrySubState.today)
    title: model.text
    description: model.description

    property bool isArchived: date.getTime() < today.getTime()
    editable: !isArchived

    menu: Component {
        ContextMenu {
            property bool isToday: date.getTime() === today.getTime()
            property bool isThisWeek: date.getTime() === thisweek.getTime()
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
                onClicked: (isSomeday || isThisWeek) ?  moveAndMarkItem(index, EntryState.done, subState, today) : markItemAs(index, EntryState.done, subState);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && isToday
                         && entryState !== EntryState.done
                         && subState !== EntrySubState.tomorrow
                         && subState !== EntrySubState.thisweek
                text: qsTr("done for today, continue tomorrow")
                onClicked: copyAndMarkItem(index, EntryState.done, EntrySubState.tomorrow, tomorrow);
            }
            MenuItem {
                visible:    editable && !isArchived
                            && (isSomeday || isThisWeek)
                            && (entryState === EntryState.todo || entryState === EntryState.ignored)
                text: qsTr("handle today")
                onClicked: moveAndMarkItem(index, EntryState.todo, EntrySubState.today, today);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && !isSomeday && !isThisWeek
                         && entryState === EntryState.done
                         && subState !== EntrySubState.tomorrow
                         && subState !== EntrySubState.thisweek
                         && subState !== EntrySubState.someday
                text: isToday ? qsTr("continue tomorrow") : qsTr("continue next day")
                onClicked: copyAndMarkItem(index, EntryState.done, EntrySubState.tomorrow, Helpers.getDate(1, date));
            }
            MenuItem {
                visible: {
                    if (!editable || isArchived) return false;
                    if (isSomeday) return true;
                    if (isThisWeek) return false;
                    if (subState === EntrySubState.thisweek) return false;
                    if (isToday && subState === EntrySubState.today) return true;
                    if (date.getTime() > today.getTime()) return true;
                    return false;
                }
                text: entryState !== EntryState.todo ? qsTr("continue later this week") : qsTr("handle later this week")
                onClicked: (isSomeday || isThisWeek) ? moveAndMarkItem(index, EntryState.todo, EntrySubState.thisweek, thisweek) :
                                                       copyAndMarkItem(index, EntryState.ignored, EntrySubState.thisweek, thisweek); // "source" will be marked as ignored
            }
            MenuItem {
                visible:    editable && !isArchived
                         && !isToday
                         && !isSomeday
                         && entryState === EntryState.todo
                         && subState !== EntrySubState.tomorrow
                text: qsTr("move to someday later")
                onClicked: (isThisWeek) ? moveAndMarkItem(index, EntryState.todo, EntrySubState.someday, someday) :
                                          copyAndMarkItem(index, EntryState.ignored, EntrySubState.someday, someday); // "source" will be marked as ignored
            }
            MenuItem {
                visible:    editable && !isArchived
                         && entryState === EntryState.todo
                text: qsTr("ignore")
                onClicked: (isSomeday || isThisWeek) ?  moveAndMarkItem(index, EntryState.ignored, EntrySubState.today, today) : markItemAs(index, EntryState.ignored, subState);
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
                            else if (subState === EntrySubState.thisweek) text = text.arg(qsTr("to be done later this week"))
                            else if (subState === EntrySubState.someday) text = text.arg(qsTr("to be done someday later"))
                        } else if (entryState === EntryState.done) {
                            if (subState === EntrySubState.today) text = text.arg(isToday ? qsTr("done today") : qsTr("done this day"))
                            else if (subState === EntrySubState.tomorrow) text = text.arg(isToday ? qsTr("continue tomorrow") : qsTr("continue next day"))
                            else if (subState === EntrySubState.thisweek) text = text.arg(qsTr("continue later this week"))
                            else if (subState === EntrySubState.someday) text = text.arg(qsTr("continue someday later"))
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
