import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../config" 1.0

SilicaListView {
    id: view

    signal toggleShowSection(var section)

    delegate: TodoListItem {
        onMarkItemAs: main.markItemAs(view.model.mapToSource(which), mainState, subState, copyToDate);
        onSaveItemTexts: updateItem(view.model.mapToSource(which), undefined, undefined, newText, newDescription);
        onDeleteThisItem: deleteItem(view.model.mapToSource(which))
        Component.onCompleted: {
            view.toggleShowSection.connect(function(section) {
                if (section.split("T")[0] === getDateString(date)) hidden = !hidden;
            })
        }
    }

    section {
        property: 'date'
        delegate: Column {
            width: parent.width
            property bool open: true
            property bool isToday: String(section).split("T")[0] === getDateString(today)
            property bool isTomorrow: String(section).split("T")[0] === getDateString(tomorrow)

            Spacer { height: Theme.paddingLarge }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall

                onClicked: {
                    open = !open;
                    view.toggleShowSection(section);
                }

                Label {
                    id: titleLabel
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        right: subtitleLabel.left
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    text: {
                        if (isToday) qsTr("Today")
                        else if (isTomorrow) qsTr("Tomorrow")
                        else new Date(section).toLocaleString(Qt.locale(), "dddd")
                    }
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }

                Label {
                    id: subtitleLabel
                    anchors {
                        right: moreImage.left
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    text: new Date(section).toLocaleString(Qt.locale(), (isToday || isTomorrow) ?
                                                               main.fullDateFormat : main.shortDateFormat)
                    color: Theme.highlightColor
                    opacity: Theme.opacityHigh
                    font.pixelSize: Theme.fontSizeSmall
                }

                Image {
                    id: moreImage
                    anchors {
                        right: parent.right
                        rightMargin: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    source: "image://theme/icon-m-right?" + Theme.highlightColor
                    transformOrigin: Item.Center
                    rotation: open ? 90 : 0
                    Behavior on rotation { NumberAnimation { duration: 100 } }
                }

                Rectangle {
                    anchors.fill: parent
                    z: -1 // behind everything
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            Spacer { height: Theme.paddingMedium }
        }
    }

    ViewPlaceholder {
        enabled: view.count == 0 && startupComplete
        text: qsTr("No entries yet")
        hintText: qsTr("Pull down to add entries")
    }
}
