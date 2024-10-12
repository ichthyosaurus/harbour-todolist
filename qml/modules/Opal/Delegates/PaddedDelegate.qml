//@ This file is part of opal-delegates.
//@ https://github.com/Pretty-SFOS/opal-delegates
//@ SPDX-FileCopyrightText: 2023 Peter G. (nephros)
//@ SPDX-FileCopyrightText: 2024 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.0
import Sailfish.Silica 1.0
import"private"
ListItem{id:root
property bool showOddEven:false
property color oddColor:"transparent"
property color evenColor:Theme.highlightBackgroundColor
property bool _isOddRow:typeof index!=="undefined"&&(index%2!=0)
readonly property int _modelIndex:typeof index!=="undefined"?index:-1
property bool interactive:true
property Component leftItem:null
readonly property alias centerItem:centerItem
property Component rightItem:null
property bool loadSideItemsAsync:false
default property alias contents:centerItem.data
property var centeredContainer
property int minContentHeight:Theme.itemSizeMedium
property int spacing:Theme.paddingMedium
property int rightItemAlignment:Qt.AlignVCenter
property int leftItemAlignment:Qt.AlignVCenter
readonly property PaddingData padding:PaddingData{readonly property int __defaultLeftRight:Theme.horizontalPageMargin
readonly property int __defaultTopBottom:Theme.paddingSmall
leftRight:!_isDefined(all)&&(!_isDefined(left)||!_isDefined(right))?__defaultLeftRight:NaN
topBottom:!_isDefined(all)&&(!_isDefined(top)||!_isDefined(bottom))?__defaultTopBottom:NaN
}
property var dragHandler:null
readonly property var _effectiveDragHandler:!!dragHandler&&dragHandler.hasOwnProperty("__opal_view_drag_handler")?dragHandler:null
property int dragHandleAlignment:leftItemAlignment===Qt.AlignTop||rightItemAlignment===Qt.AlignTop?Qt.AlignTop:Qt.AlignVCenter
property bool hideRightItemWhileDragging:true
readonly property bool draggable:!!_effectiveDragHandler&&!!_effectiveDragHandler.active
function toggleWrappedText(label){label.wrapped=!label.wrapped
}opacity:enabled?1.0:Theme.opacityLow
Binding on highlighted{when:!interactive
value:true
}Binding on _backgroundColor{when:!interactive
value:"transparent"
}contentHeight:hidden?0:Math.max(topPaddingItem.height+bottomPaddingItem.height+Math.max(leftItemLoader.height,rightItemLoader.height,centerItem.height),minContentHeight)
Item{id:topPaddingItem
anchors.bottom:centerItem.top
width:root.width
height:padding.effectiveTop
}Item{id:bottomPaddingItem
anchors.top:centerItem.bottom
width:root.width
height:padding.effectiveBottom
}Item{id:leftPaddingItem
anchors.left:parent.left
width:padding.effectiveLeft
height:contentHeight
}Item{id:rightPaddingItem
anchors.right:parent.right
width:padding.effectiveRight
height:contentHeight
}Loader{id:leftItemLoader
sourceComponent:leftItem
asynchronous:loadSideItemsAsync
anchors{left:leftPaddingItem.right
verticalCenter:parent.verticalCenter
}Binding{target:!!leftItemLoader.item&&leftItemLoader.item.hasOwnProperty("_delegate")?leftItemLoader.item:null
property:"_delegate"
value:root
}states:[State{when:leftItemAlignment==Qt.AlignVCenter
AnchorChanges{target:leftItemLoader
anchors.verticalCenter:leftItemLoader.parent.verticalCenter
anchors.top:undefined
anchors.bottom:undefined
}},State{when:leftItemAlignment==Qt.AlignTop
AnchorChanges{target:leftItemLoader
anchors.verticalCenter:undefined
anchors.top:topPaddingItem.bottom
anchors.bottom:undefined
}},State{when:leftItemAlignment==Qt.AlignBottom
AnchorChanges{target:leftItemLoader
anchors.verticalCenter:undefined
anchors.top:undefined
anchors.bottom:bottomPaddingItem.top
}}]}Loader{id:rightItemLoader
visible:!hideRightItemWhileDragging||!dragHandleLoader.visible
sourceComponent:rightItem
asynchronous:loadSideItemsAsync
anchors{right:dragHandleLoader.left
rightMargin:dragHandleLoader.width>0?spacing:0
verticalCenter:parent.verticalCenter
}Binding{target:!!rightItemLoader.item&&rightItemLoader.item.hasOwnProperty("_delegate")?rightItemLoader.item:null
property:"_delegate"
value:root
}states:[State{when:rightItemAlignment==Qt.AlignVCenter
AnchorChanges{target:rightItemLoader
anchors.verticalCenter:rightItemLoader.parent.verticalCenter
anchors.top:undefined
anchors.bottom:undefined
}},State{when:rightItemAlignment==Qt.AlignTop
AnchorChanges{target:rightItemLoader
anchors.verticalCenter:undefined
anchors.top:topPaddingItem.bottom
anchors.bottom:undefined
}},State{when:rightItemAlignment==Qt.AlignBottom
AnchorChanges{target:rightItemLoader
anchors.verticalCenter:undefined
anchors.top:undefined
anchors.bottom:bottomPaddingItem.top
}}]}Loader{id:dragHandleLoader
visible:status===Loader.Ready&&draggable
property QtObject viewHandler:_effectiveDragHandler
property Item handledItem:root
property int modelIndex:root._modelIndex
source:!!_effectiveDragHandler?Qt.resolvedUrl("private/OptionalDragHandle.qml"):""
asynchronous:false
height:contentHeight
anchors{right:rightPaddingItem.left
top:parent.top
}Binding{target:!!dragHandleLoader.item&&dragHandleLoader.item.hasOwnProperty("_delegate")?dragHandleLoader.item:null
property:"_delegate"
value:root
}}SilicaItem{id:centerItem
height:Math.max(minContentHeight,childrenRect.height)
anchors{left:leftItemLoader.right
leftMargin:leftItemLoader.width>0?spacing:0
right:rightItemLoader.left
rightMargin:rightItemLoader.width>0?spacing:0
verticalCenter:parent.verticalCenter
}states:State{when:dragHandleLoader.visible
AnchorChanges{target:centerItem
anchors.right:dragHandleLoader.left
}PropertyChanges{target:centerItem
anchors.rightMargin:dragHandleLoader.width>0?spacing:0
}}}Rectangle{id:emphasisBackground
anchors.fill:parent
visible:showOddEven
radius:Theme.paddingSmall
opacity:Theme.opacityFaint
color:_isOddRow?oddColor:evenColor
border{color:"transparent"
width:radius/2
}}states:[State{name:"tall"
when:!!centeredContainer&&(centeredContainer.height>minContentHeight||centeredContainer.implicitHeight>minContentHeight||centeredContainer.childrenRect.height>minContentHeight)
AnchorChanges{target:centeredContainer
anchors{verticalCenter:undefined
top:centeredContainer.parent.top
}}},State{name:"short"
when:!!centeredContainer&&(centeredContainer.height<=minContentHeight||centeredContainer.implicitHeight<=minContentHeight||centeredContainer.childrenRect.height<=minContentHeight)
AnchorChanges{target:centeredContainer
anchors{top:undefined
verticalCenter:centeredContainer.parent.verticalCenter
}}}]}