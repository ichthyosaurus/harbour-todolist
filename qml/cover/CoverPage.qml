import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../constants" 1.0

CoverBackground {
    SortFilterProxyModel {
        id: firstPassFilteredModel
        sourceModel: rawModel

        sorters: [
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "weight"; sortOrder: Qt.DescendingOrder }
        ]

        filters: [
            ValueFilter {
                roleName: "date"
                value: today
            },
            AnyOf {
                ValueFilter {
                    roleName: "entryState"
                    value: EntryState.todo
                }
                ValueFilter {
                    roleName: "entryState"
                    value: EntryState.ignored
                }
            }
        ]
    }

    property int currentPageNumber: 1
    property int maxPerPage: 10

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: firstPassFilteredModel

        filters: IndexFilter {
            maximumIndex: currentPageNumber*maxPerPage
            minimumIndex: maximumIndex-maxPerPage
        }
    }

    SilicaListView {
        id: view
        anchors {
            top: parent.top; topMargin: Theme.paddingMedium
            left: parent.left; leftMargin: Theme.paddingMedium
            right: parent.right; rightMargin: Theme.paddingMedium
            bottom: parent.bottom; bottomMargin: Theme.paddingMedium
        }

        model: filteredModel
        delegate: ListItem {
            id: item
            anchors.topMargin:  Theme.paddingSmall
            height: entryLabel.height + Theme.paddingSmall
            opacity: 1.0 - index * 0.05

            property int yoff: Math.round(item.y - view.contentY)
            property bool isFullyVisible: (yoff > view.y && yoff + height < view.y + view.height)
            visible: isFullyVisible

            HighlightImage {
                id: statusIcon
                width: 0.8*Theme.iconSizeExtraSmall
                height: width
                anchors { top: parent.top; topMargin: Theme.paddingSmall }
                color: Theme.primaryColor
                source: {
                    if (entryState === EntryState.todo) "../images/icon-todo-small.png"
                    else if (entryState === EntryState.ignored) "../images/icon-ignored-small.png"
                    else if (entryState === EntryState.done) "../images/icon-done-small.png"
                }
            }

            Label {
                id: entryLabel
                maximumLineCount: 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: model.text
                truncationMode: TruncationMode.Fade
                anchors { leftMargin: Theme.paddingSmall; left: statusIcon.right; right: parent.right }
            }
        }
    }

//    CoverActionList {
//        id: coverActionList

//        CoverAction {
//            iconSource: "image://theme/icon-cover-previous"
//        }

//        CoverAction {
//            iconSource: "image://theme/icon-cover-new"
//        }

//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }
//    }
}
