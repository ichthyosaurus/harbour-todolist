import QtQuick 2.0
import Sailfish.Silica 1.0
import "../constants" 1.0

ListItem {
    id: item
    width: ListView.view.width
    contentHeight: row.height + (isEditing ? editButtonRow.height : 0)
    ListView.onRemove: animateRemoval(item) // enable animated list item removals

    property string title: ""
    property string description: ""
    property bool infoMarkerEnabled: false
    property bool editable: true
    property bool descriptionEnabled: true
    property bool customClickHandlingEnabled: false

    property bool isEditing: false
    signal markItemAs(var which, var mainState, var subState)
    signal copyAndMarkItem(var which, var mainState, var subState, var copyToDate)
    signal saveItemTexts(var which, var newText, var newDescription)
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
                var dialog = pageStack.push(Qt.resolvedUrl("../pages/ConfirmDeleteDialog.qml"),
                                            { text: title, description: description })
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
                    visible: !isEditing
                    width: parent.width
                    text: title
                    font.pixelSize: Theme.fontSizeMedium
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
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
                    visible: !isEditing && infoMarkerEnabled
                    width: Theme.iconSizeExtraSmall
                    text: "⭑"
                    color: Theme.highlightColor
                    opacity: Theme.opacityHigh
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
            text: qsTr("Abort")
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
