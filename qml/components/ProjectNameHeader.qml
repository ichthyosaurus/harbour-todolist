import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property string text: currentProjectName

    width: parent.width
    height: childrenRect.height

    Label {
        id: titleLabel
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Theme.horizontalPageMargin
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        text: root.text
        color: Theme.highlightColor
        font {
            pixelSize: Theme.fontSizeMedium
            family: Theme.fontFamilyHeading
        }
    }

    Separator {
        anchors {
            // FIXME if the label has more than one line then
            //       we're stuck at the baseline of the first line
            top: titleLabel.baseline
            topMargin: Theme.paddingSmall
        }

        width: titleLabel.width
        horizontalAlignment: Qt.AlignHCenter
        color: Theme.secondaryHighlightColor
    }
}
