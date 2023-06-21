/*
 * This file is part of harbour-todolist.
 *
 * SPDX-FileCopyrightText: 2020-2021 Mirian Margiani
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * harbour-todolist is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * harbour-todolist is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Harbour.Todolist 1.0
import "../js/helpers.js" as Helpers

TodoListBaseItem {
    id: item
    descriptionEnabled: true
    infoMarkerEnabled: (createdOn.getTime() !== date.getTime() || subState !== Entry.TODAY)
    title: model.text
    description: model.description
    project: model.project

    property bool isArchived: date.getTime() < today.getTime()
    editable: !isArchived

    menu: Component {
        ContextMenu {
            property bool isToday: date.getTime() === today.getTime()
            property bool isThisWeek: date.getTime() === thisweek.getTime()
            property bool isSomeday: date.getTime() === someday.getTime()

            MenuItem {
                visible: isArchived && (   entryState !== Entry.TODO
                                        || date.getTime() > main.configuration.lastCarriedOverFrom.getTime())
                text: qsTr("continue today")
                onClicked: copyAndMarkItem(index, Entry.TODO, Entry.TOMORROW, today);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && entryState !== Entry.DONE
                text: qsTr("done")
                onClicked: (isSomeday || isThisWeek) ?  moveAndMarkItem(index, Entry.DONE, subState, today) : markItemAs(index, Entry.DONE, subState);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && isToday
                         && entryState !== Entry.DONE
                         && subState !== Entry.TOMORROW
                         && subState !== Entry.THIS_WEEK
                text: qsTr("done for today, continue tomorrow")
                onClicked: copyAndMarkItem(index, Entry.DONE, Entry.TOMORROW, tomorrow);
            }
            MenuItem {
                visible:    editable && !isArchived
                            && (isSomeday || isThisWeek)
                            && (entryState === Entry.TODO || entryState === Entry.IGNORED)
                text: qsTr("handle today")
                onClicked: moveAndMarkItem(index, Entry.TODO, Entry.TODAY, today);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && !isSomeday && !isThisWeek
                         && entryState === Entry.DONE
                         && subState !== Entry.TOMORROW
                         && subState !== Entry.THIS_WEEK
                         && subState !== Entry.SOMEDAY
                text: isToday ? qsTr("continue tomorrow") : qsTr("continue next day")
                onClicked: copyAndMarkItem(index, Entry.DONE, Entry.TOMORROW, Helpers.getDate(1, date));
            }
            MenuItem {
                visible: {
                    if (!editable || isArchived) return false;
                    if (isSomeday) return true;
                    if (isThisWeek) return false;
                    if (subState === Entry.THIS_WEEK) return false;
                    if (isToday && subState === Entry.TODAY) return true;
                    if (date.getTime() > today.getTime()) return true;
                    return false;
                }
                text: entryState !== Entry.TODO ? qsTr("continue later this week") : qsTr("handle later this week")
                onClicked: (isSomeday || isThisWeek) ? moveAndMarkItem(index, Entry.TODO, Entry.THIS_WEEK, thisweek) :
                                                       copyAndMarkItem(index, Entry.IGNORED, Entry.THIS_WEEK, thisweek); // "source" will be marked as ignored
            }
            MenuItem {
                visible:    editable && !isArchived
                         && !isToday
                         && !isSomeday
                         && entryState === Entry.TODO
                         && subState !== Entry.TOMORROW
                text: qsTr("move to someday later")
                onClicked: (isThisWeek) ? moveAndMarkItem(index, Entry.TODO, Entry.SOMEDAY, someday) :
                                          copyAndMarkItem(index, Entry.IGNORED, Entry.SOMEDAY, someday); // "source" will be marked as ignored
            }
            MenuItem {
                visible:    editable && !isArchived
                         && entryState === Entry.TODO
                text: qsTr("ignore")
                onClicked: (isSomeday || isThisWeek) ?  moveAndMarkItem(index, Entry.IGNORED, Entry.TODAY, today) : markItemAs(index, Entry.IGNORED, subState);
            }
            MenuItem {
                visible:    editable && !isArchived
                         && entryState === Entry.DONE
                text: qsTr("not completely done yet")
                onClicked: markItemAs(index, Entry.TODO, subState);
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

                        if (entryState === Entry.TODO) {
                            if (subState === Entry.TODAY) {
                                if (!isSomeday) text = text.arg(isToday ? qsTr("for today") : qsTr("for this day"))
                                else text = text.arg(qsTr("for someday later"))
                            } else text = text.arg(qsTr("carried over"))
                        } else if (entryState === Entry.IGNORED) {
                            if (subState === Entry.TODAY) text = text.arg(isToday ? qsTr("ignored today") : qsTr("ignored this day"))
                            else if (subState === Entry.TOMORROW) text = text.arg(isToday ? qsTr("to be done tomorrow") : qsTr("to be done next day"))
                            else if (subState === Entry.THIS_WEEK) text = text.arg(qsTr("to be done later this week"))
                            else if (subState === Entry.SOMEDAY) text = text.arg(qsTr("to be done someday later"))
                        } else if (entryState === Entry.DONE) {
                            if (subState === Entry.TODAY) text = text.arg(isToday ? qsTr("done today") : qsTr("done this day"))
                            else if (subState === Entry.TOMORROW) text = text.arg(isToday ? qsTr("continue tomorrow") : qsTr("continue next day"))
                            else if (subState === Entry.THIS_WEEK) text = text.arg(qsTr("continue later this week"))
                            else if (subState === Entry.SOMEDAY) text = text.arg(qsTr("continue someday later"))
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
