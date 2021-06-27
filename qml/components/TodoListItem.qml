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
import "../constants" 1.0
import "../js/helpers.js" as Helpers

TodoListBaseItem {
    id: item
    descriptionEnabled: true
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
                visible: isArchived && (   entryState !== EntryState.todo
                                        || date.getTime() > main.configuration.lastCarriedOverFrom.getTime())
                text: qsTr("continue today")
                onClicked: copyAndMarkItem(index, EntryState.todo, EntrySubState.tomorrow, today);
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
                visible: editable
                text: {
                    var text = "";
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
