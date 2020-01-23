import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config" 1.0

ListItem {
    id: item
    width: ListView.view.width
    contentHeight: row.height + (isEditing ? editButtonRow.height : 0)
    ListView.onRemove: animateRemoval(item) // enable animated list item removals

    property bool isEditing: false
    property bool editable: true
    signal markItemAs(var which, var mainState, var subState)
    signal copyAndMarkItem(var which, var mainState, var subState, var copyToDate)
    signal saveItemTexts(var which, var newText, var newDescription)
    signal deleteThisItem(var which)

    function startEditing() {
        isEditing = true;
        item.enabled = false;
        editDescriptionField.text = description;
        editTextField.text = text;
    }

    function stopEditing() {
        isEditing = false;
        item.enabled = true;
    }

    showMenuOnPressAndHold: false
    onPressAndHold: if (editable) startEditing();
    onClicked: openMenu()
    menu: Component {
        ContextMenu {
            MenuItem {
                visible: !editable
                text: qsTr("continue today")
                onClicked: copyAndMarkItem(index, entrystate, EntrySubState.tomorrow, today);
            }

            MenuItem {
                visible: editable && entrystate !== EntryState.done
                text: qsTr("done")
                onClicked: markItemAs(index, EntryState.done, substate);
            }
            MenuItem {
                visible: editable && entrystate !== EntryState.done && substate !== EntrySubState.tomorrow
                text: qsTr("done for today, continue tomorrow")
                onClicked: copyAndMarkItem(index, EntryState.done, EntrySubState.tomorrow, getDate(1, date));
            }
            MenuItem {
                visible: editable && entrystate === EntryState.todo && substate !== EntrySubState.tomorrow
                text: qsTr("move to tomorrow")
                onClicked: copyAndMarkItem(index, EntryState.ignored, EntrySubState.tomorrow, getDate(1, date));
            }
            MenuItem {
                visible: editable && entrystate === EntryState.todo
                text: qsTr("ignore")
                onClicked: markItemAs(index, EntryState.ignored, substate);
            }
            MenuItem {
                visible: editable && entrystate === EntryState.done && substate !== EntrySubState.tomorrow
                text: qsTr("continue tomorrow")
                onClicked: copyAndMarkItem(index, EntryState.done, EntrySubState.tomorrow, getDate(1, date));
            }
            MenuItem {
                visible: editable && entrystate === EntryState.done
                text: qsTr("not completely done yet")
                onClicked: markItemAs(index, EntryState.todo, substate);
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

                    if (entrystate === EntryState.todo) {
                        if (substate === EntrySubState.today) text = text.arg(qsTr("for today"))
                        else if (substate === EntrySubState.tomorrow) text = text.arg(qsTr("carried over"))
                    } else if (entrystate === EntryState.ignored) {
                        if (substate === EntrySubState.today) text = text.arg(qsTr("ignored today"))
                        else if (substate === EntrySubState.tomorrow) text = text.arg(qsTr("to be done tomorrow"))
                    } else if (entrystate === EntryState.done) {
                        if (substate === EntrySubState.today) text = text.arg(qsTr("done today"))
                        else if (substate === EntrySubState.tomorrow) text = text.arg(qsTr("continue tomorrow"))
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
            visible: !isEditing
            highlighted: item.highlighted
            width: Theme.iconSizeSmallPlus
            height: width
            anchors.top: parent.top
            anchors.topMargin: parent.anchors.topMargin
        }

        IconButton {
            id: deleteButton
            visible: isEditing
            anchors.fill: statusIcon // FIXME not possible in a Row
            icon.source: "image://theme/icon-m-delete"
            onClicked: {
                var dialog = pageStack.push(Qt.resolvedUrl("ConfirmDeleteDialog.qml"),
                                            { text: text, description: description })
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
                width: parent.width-Theme.horizontalPageMargin

                Label {
                    id: taskText
                    visible: !isEditing
                    width: parent.width
                    text: model.text
                    font.pixelSize: Theme.fontSizeMedium
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                }

                TextField {
                    id: editTextField
                    visible: isEditing
                    z: row.z-1
                    placeholderText: model.text
                    text: model.text
                    labelVisible: false
                    textTopMargin: 0
                    textMargin: 0
                    width: parent.width
                }

                Label {
                    id: hasInfoLabel
                    visible: !isEditing && (createdOn.getTime() !== date.getTime() || substate === EntrySubState.tomorrow)
                    width: Theme.iconSizeExtraSmall
                    text: "⭑"
                    color: Theme.highlightColor
                    opacity: Theme.opacityHigh
                }
            }

            Label {
                visible: description !== "" && !isEditing
                opacity: Theme.opacityHigh
                width: parent.width
                text: description
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.PlainText
                elide: Text.ElideRight
                truncationMode: TruncationMode.Fade
                maximumLineCount: 8
                wrapMode: Text.WordWrap
            }

            TextArea {
                id: editDescriptionField
                visible: isEditing
                z: row.z-1
                placeholderText: description !== "" ? description : qsTr("Description (optional)")
                text: description
                labelVisible: false
                textTopMargin: 0
                textMargin: 0
                width: parent.width
            }

            Spacer { height: Theme.paddingMedium }
        }
    }

    Row {
        id: editButtonRow
        visible: isEditing
        anchors.top: row.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge

        Button {
            text: qsTr("Save")
            onClicked: {
                var newText = editTextField.text;
                var newDescription = editDescriptionField.text;
                if (newText === "") return;
                saveItemTexts(index, newText.trim(), newDescription.trim());
                stopEditing();
            }
        }

        Button {
            text: qsTr("Abort")
            onClicked: stopEditing();
        }
    }

    states: [
        State {
            name: "todo"
            when: entrystate === EntryState.todo
            PropertyChanges { target: statusIcon; source: "../images/icon-todo.png"; opacity: Theme.opacityHigh }
        },
        State {
            name: "ignored"
            when: entrystate === EntryState.ignored
            PropertyChanges { target: statusIcon; source: "../images/icon-ignored.png"; }
            PropertyChanges { target: row; opacity: Theme.opacityHigh }
        },
        State {
            name: "done"
            when: entrystate === EntryState.done
            PropertyChanges { target: statusIcon; source: "../images/icon-done.png"; }
            PropertyChanges { target: row; opacity: Theme.opacityLow }
        }
    ]
}
