import QtQuick 2.0
import Sailfish.Silica 1.0
import "../constants" 1.0

PageHeader {
    clip: true

    property int showNavigation: FakeNavigation.None
    property bool _showLeftNavigation: showNavigation === FakeNavigation.Left || showNavigation === FakeNavigation.Both
    property bool _showRightNavigation: showNavigation === FakeNavigation.Right || showNavigation === FakeNavigation.Both

    GlassItem {
        id: indicatorLeft
        visible: _showLeftNavigation

        anchors {
            left: parent.left
            leftMargin: -(width/2)
            verticalCenter: _titleItem.verticalCenter
        }

        color: mouseLeft.pressed ? Theme.highlightColor : Theme.lightPrimaryColor
        backgroundColor: Theme.backgroundGlowColor
        radius: 0.22
        falloffRadius: 0.18

        MouseArea {
            id: mouseLeft
            enabled: _showLeftNavigation
            anchors.fill: parent
            onClicked: main.fakeNavigateLeft()
        }
    }

    GlassItem {
        id: indicatorRight
        visible: _showRightNavigation

        anchors {
            right: parent.right
            rightMargin: -(width/2)
            verticalCenter: _titleItem.verticalCenter
        }

        color: mouseRight.pressed ? Theme.highlightColor : Theme.lightPrimaryColor
        backgroundColor: Theme.backgroundGlowColor
        radius: 0.22
        falloffRadius: 0.18

        MouseArea {
            id: mouseRight
            enabled: _showRightNavigation
            anchors.fill: parent
            onClicked: main.fakeNavigateRight()
        }
    }
}
