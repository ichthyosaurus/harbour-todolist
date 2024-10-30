//@ This file is part of Opal.TabBar.
//@ SPDX-FileCopyrightText: 2024 Mirian Margiani
//@ SPDX-FileCopyrightText: Copyright (C) 2019 Open Mobile Platform LLC.
//@ SPDX-License-Identifier: GPL-3.0-or-later
//@
//@ /****************************************************************************************
//@ **
//@ ** Copyright (C) 2019 Open Mobile Platform LLC.
//@ ** All rights reserved.
//@ **
//@ ** This file is part of Sailfish Silica UI component package.
//@ **
//@ ** You may use this file under the terms of BSD license as follows:
//@ **
//@ ** Redistribution and use in source and binary forms, with or without
//@ ** modification, are permitted provided that the following conditions are met:
//@ **     * Redistributions of source code must retain the above copyright
//@ **       notice, this list of conditions and the following disclaimer.
//@ **     * Redistributions in binary form must reproduce the above copyright
//@ **       notice, this list of conditions and the following disclaimer in the
//@ **       documentation and/or other materials provided with the distribution.
//@ **     * Neither the name of the Jolla Ltd nor the
//@ **       names of its contributors may be used to endorse or promote products
//@ **       derived from this software without specific prior written permission.
//@ **
//@ ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//@ ** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//@ ** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//@ ** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
//@ ** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//@ ** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//@ ** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//@ ** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//@ ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//@ ** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//@ **
//@ ****************************************************************************************/
import QtQuick 2.0;import Sailfish.Silica 1.0;import"private/Util.js"as Util;SilicaControl{id:root;default property alias contents:bodyItem.data;property int topMargin:parent._ctxTopMargin||_ctxTopMargin||0;property int bottomMargin:parent._ctxBottomMargin||_ctxBottomMargin||0;property Flickable flickable;property bool allowDeletion:true;readonly property bool isCurrentItem:_tabContainer&&_tabContainer.PagedView.isCurrentItem;property Item _tabContainer:parent._ctxTabContainer||_ctxTabContainer||root;property Item _page:parent._ctxPage||_ctxPage;readonly property real _yOffset:flickable&&flickable.pullDownMenu?flickable.contentY-flickable.originY:0;property alias _cacheExpiry:cleanupTimer.interval;implicitWidth:_tabContainer?_tabContainer.PagedView.contentWidth:0;implicitHeight:{if(!_tabContainer){return 0;}else{var view=flickable&&flickable.pullDownMenu?_tabContainer.PagedView.view:null;return view?view.height:_tabContainer.PagedView.contentHeight;}}opacity:0;clip:!flickable||!flickable.pullDownMenu||!flickable.pushUpMenu;Component.onCompleted:{if(_tabContainer&&!!_tabContainer.DelegateModel){_tabContainer.DelegateModel.inPersistedItems=true;}if(!flickable){for(var child in children){if(child.hasOwnProperty("maximumFlickVelocity")&&!child.hasOwnProperty("__silica_hidden_flickable")){flickable=child;break;}}}}Binding{target:!!flickable&&flickable.pullDownMenu?flickable.pullDownMenu:null;property:"y";when:topMargin>0;value:flickable.originY-flickable.pullDownMenu.height-root.topMargin+(_page.orientation&Orientation.PortraitMask?0:Theme.paddingMedium);}Timer{id:cleanupTimer;running:root.allowDeletion&&root._tabContainer&&!root._tabContainer.PagedView.exposed;interval:30000;onTriggered:{if(!!_tabContainer&&!!_tabContainer.DelegateModel){_tabContainer.DelegateModel.inPersistedItems=false;}}}SilicaItem{id:bodyItem;anchors{top:parent.top;topMargin:root.topMargin;}implicitWidth:parent.implicitWidth;implicitHeight:parent.implicitHeight-parent.topMargin-parent.bottomMargin;}}