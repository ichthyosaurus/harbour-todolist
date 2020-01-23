import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"

Dialog {
    id: dialog
    property string text
    property string description
    property bool _showDescription: description != ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }

            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Delete")
                cancelText: qsTr("Abort")
            }

            SectionHeader {
                text: qsTr("Text")
            }
            Label {
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                font.pixelSize: Theme.fontSizeMedium
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                text: dialog.text
            }

            SectionHeader {
                visible: _showDescription
                text: qsTr("Description")
            }
            Label {
                anchors {
                    left: parent.left; right: parent.right;
                    leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin;
                }
                font.pixelSize: Theme.fontSizeMedium
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                visible: _showDescription
                text: dialog.description
            }

            Spacer { }
        }
    }
}
