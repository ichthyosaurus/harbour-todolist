import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config" 1.0

TodoListBaseItem {
    id: item
    editable: true
    descriptionEnabled: true

    menu: Component {
        ContextMenu {
            MenuItem {
                visible: !editable
                text: qsTr("continue today")
                onClicked: copyAndMarkItem(index, entryState, EntrySubState.tomorrow, today);
            }

            MenuItem {
                visible: editable && entryState !== EntryState.done
                text: qsTr("done")
                onClicked: markItemAs(index, EntryState.done, subState);
            }
            MenuItem {
                visible: editable && entryState !== EntryState.done && subState !== EntrySubState.tomorrow
                text: qsTr("done for today, continue tomorrow")
                onClicked: copyAndMarkItem(index, EntryState.done, EntrySubState.tomorrow, getDate(1, date));
            }
            MenuItem {
                visible: editable && entryState === EntryState.todo && subState !== EntrySubState.tomorrow
                text: qsTr("move to tomorrow")
                onClicked: copyAndMarkItem(index, EntryState.ignored, EntrySubState.tomorrow, getDate(1, date));
            }
            MenuItem {
                visible: editable && entryState === EntryState.todo
                text: qsTr("ignore")
                onClicked: markItemAs(index, EntryState.ignored, subState);
            }
            MenuItem {
                visible: editable && entryState === EntryState.done && subState !== EntrySubState.tomorrow
                text: qsTr("continue tomorrow")
                onClicked: copyAndMarkItem(index, EntryState.done, EntrySubState.tomorrow, getDate(1, date));
            }
            MenuItem {
                visible: editable && entryState === EntryState.done
                text: qsTr("not completely done yet")
                onClicked: markItemAs(index, EntryState.todo, subState);
            }
            MenuItem {
                enabled: false
                visible: hasInfoLabel.visible
                text: {
                    var text = qsTr("⭑ %1, %2")

                    if (createdOn.getTime() === date.getTime()) {
                        text = text.arg(qsTr("from today"));
                    } else if (createdOn.getTime() === getDate(-1, date).getTime()) {
                        text = text.arg(qsTr("from yesterday"));
                    } else {
                        text = text.arg(qsTr("from earlier"));
                    }

                    if (entryState === EntryState.todo) {
                        if (subState === EntrySubState.today) text = text.arg(qsTr("for today"))
                        else if (subState === EntrySubState.tomorrow) text = text.arg(qsTr("carried over"))
                    } else if (entryState === EntryState.ignored) {
                        if (subState === EntrySubState.today) text = text.arg(qsTr("ignored today"))
                        else if (subState === EntrySubState.tomorrow) text = text.arg(qsTr("to be done tomorrow"))
                    } else if (entryState === EntryState.done) {
                        if (subState === EntrySubState.today) text = text.arg(qsTr("done today"))
                        else if (subState === EntrySubState.tomorrow) text = text.arg(qsTr("continue tomorrow"))
                    }

                    return text;
                }
                font.pixelSize: Theme.fontSizeSmall
            }
            MenuItem {
                visible: editable
                enabled: false
                text: qsTr("press and hold to edit or delete")
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
