import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    property string text
    property string description

    Column {
        width: parent.width

        DialogHeader {
            acceptText: qsTr("Delete")
            cancelText: qsTr("Abort")
        }

        Label {
            text: qsTr("Do you really want to delete this entry?")
        }

        DetailItem {
            label: qsTr("Task")
            value: dialog.text
        }

        DetailItem {
            visible: dialog.description !== ""
            label: qsTr("Description")
            value: dialog.description
        }
    }
}
