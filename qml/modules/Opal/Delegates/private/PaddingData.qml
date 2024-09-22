//@ This file is part of opal-delegates.
//@ https://github.com/Pretty-SFOS/opal-delegates
//@ SPDX-FileCopyrightText: 2024 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.0
QtObject{property int all
property int leftRight
property int topBottom
property int top
property int bottom
property int left
property int right
readonly property int effectiveTop:top>0?top:_topBottom
readonly property int effectiveBottom:bottom>0?bottom:_topBottom
readonly property int effectiveLeft:left>0?left:_leftRight
readonly property int effectiveRight:right>0?right:_leftRight
readonly property int _topBottom:topBottom>0?topBottom:all
readonly property int _leftRight:leftRight>0?leftRight:all
}