import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config" 1.0

Label {
    id: emptyPlaceholder
    property date date

    visible: entriesModel.count === 0
    wrapMode: Text.Wrap
    horizontalAlignment: Text.AlignHCenter
    font {
        pixelSize: Theme.fontSizeLarge
        family: Theme.fontFamilyHeading
    }
    x: Theme.horizontalPageMargin
    width: parent.width - 2*x
    color: Theme.secondaryHighlightColor
    text: date >= today ? qsTr("There is nothing to do.")
                        : qsTr("There was nothing to do.")
}
