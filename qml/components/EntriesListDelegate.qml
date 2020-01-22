import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config" 1.0

ListItem {
    id: item
    width: ListView.view.width
    contentHeight: row.height
    property bool editable: true

    function markItemAs(which, mainState, subState) {
        console.log("mark ->", which, mainState, subState);
        var sourceIndex = entriesModel.mapToSource(which);
        rawEntriesModel.setProperty(sourceIndex, "entrystate", mainState);
        rawEntriesModel.setProperty(sourceIndex, "substate", subState);
    }

    ListView.onRemove: animateRemoval(item) // enable animated list item removals

    showMenuOnPressAndHold: false
    // onPressAndHold: editable ? {} /*edit*/ : {}
    onClicked: (editable || hasInfoLabel.visible) ? openMenu() : {}
    menu: Component {
        ContextMenu {
            MenuItem {
                visible: editable && entrystate !== EntryState.done
                text: qsTr("done")
                onClicked: markItemAs(index, EntryState.done, substate);
            }
            MenuItem {
                visible: editable && entrystate !== EntryState.done && substate !== EntrySubState.tomorrow
                text: qsTr("done for today, continue tomorrow")
                onClicked: markItemAs(index, EntryState.done, EntrySubState.tomorrow);
            }
            MenuItem {
                visible: editable && entrystate === EntryState.todo && substate !== EntrySubState.tomorrow
                text: qsTr("move to tomorrow")
                onClicked: markItemAs(index, EntryState.ignored, EntrySubState.tomorrow);
            }
            MenuItem {
                visible: editable && entrystate === EntryState.todo
                text: qsTr("ignore")
                onClicked: markItemAs(index, EntryState.ignored, substate);
            }
            MenuItem {
                visible: editable && entrystate === EntryState.done && substate !== EntrySubState.tomorrow
                text: qsTr("continue tomorrow")
                onClicked: markItemAs(index, EntryState.done, EntrySubState.tomorrow);
            }
            MenuItem {
                visible: editable && entrystate === EntryState.done
                text: qsTr("not completely done yet")
                onClicked: markItemAs(index, EntryState.todo, substate);
            }
            MenuItem {
                enabled: false
                visible: hasInfoLabel.visible
                text: qsTr("⭑ %1, %2").arg(
                          substate === EntrySubState.today ? qsTr("done today") : qsTr("for tomorrow")).arg(
                          parentItem === "" ? qsTr("from today") : qsTr("from yesterday"))
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
            highlighted: item.highlighted
            width: Theme.iconSizeSmallPlus
            height: width
            anchors.top: parent.top
            anchors.topMargin: parent.anchors.topMargin
        }

        Column {
            id: textColumn
            anchors.top: parent.top
            width: parent.width-statusIcon.width-spacing

            Spacer { height: Theme.paddingMedium }

            Row {
                width: parent.width-Theme.horizontalPageMargin

                Label {
                    width: parent.width
                    text: model.text
                    font.pixelSize: Theme.fontSizeMedium
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                }

                Label {
                    id: hasInfoLabel
                    visible: parentItem !== "" || substate === EntrySubState.tomorrow
                    width: Theme.iconSizeExtraSmall
                    text: "⭑"
                    color: Theme.highlightColor
                    opacity: Theme.opacityHigh
                }
            }


            Label {
                visible: description !== ""
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

            Spacer { height: Theme.paddingMedium }
        }
    }

    states: [
        State {
            name: "todo"
            when: entrystate === EntryState.todo
            PropertyChanges { target: statusIcon; source: "../images/icon-todo.png" }
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
            PropertyChanges { target: row; opacity: Theme.opacityHigh }
        }
    ]
}
