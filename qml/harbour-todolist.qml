import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: main
    property date today: getDate(0)
    property date tomorrow: getDate(1)

    property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'")
    property string timeFormat: qsTr("hh':'mm")
    property string fullDateFormat: qsTr("ddd d MMM yyyy")

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    function getDate(offset) {
        var currentDate = new Date();
        currentDate.setDate(currentDate.getDate() + offset);
        currentDate.setHours(0, 0, 0, 0);
        return currentDate;
    }
}
