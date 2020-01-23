import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"

Dialog {
    id: dialog
    property date date: main.today
    property alias text: textField.text
    property alias description: descriptionField.text
    property bool descriptionEnabled: true

    canAccept: text !== ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }

            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Abort")
            }

            Label {
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                text: {
                    if (date.getTime() === today.getTime()) {
                        qsTr("Add entry for today");
                    } else if (date.getTime() === tomorrow.getTime()) {
                        qsTr("Add entry for tomorrow");
                    } else {
                        qsTr("Add entry");
                    }
                }
            }

            Spacer { }

            TextField {
                id: textField
                width: parent.width
                focus: true
                placeholderText: qsTr("Enter title")
                label: qsTr("Title")
                // inputMethodHints: Qt.ImhNoPredictiveText

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: descriptionField.forceActiveFocus();
            }

            Spacer { }

            TextArea {
                id: descriptionField
                visible: descriptionEnabled
                width: parent.width
                placeholderText: qsTr("Enter optional description")
                label: qsTr("Description")
            }

            Spacer {
                visible: descriptionEnabled
            }
        }
    }
}
