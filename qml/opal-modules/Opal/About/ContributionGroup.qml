/*
 * This file is part of opal-about.
 * Copyright (C) 2020  Mirian Margiani
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * opal-about is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * opal-about is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with opal-about.  If not, see <http://www.gnu.org/licenses/>.
 *
 * *** CHANGELOG: ***
 *
 * 2020-08-22:
 * - initial release
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject {
    property string title
    property var entries: []
}
