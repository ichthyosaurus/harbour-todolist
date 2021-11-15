#
# This file is part of harbour-todolist.
# SPDX-FileCopyrightText: 2020-2021 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later
#
# harbour-todolist is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# harbour-todolist is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with harbour-todolist.  If not, see <http://www.gnu.org/licenses/>.
#

# TRANSLATORS
# If you added a new translation catalog, please append its file name to this
# list. Just copy the last line and modify it as needed.
TRANSLATIONS += translations/harbour-todolist-en.ts \
    translations/harbour-todolist-de.ts \
    translations/harbour-todolist-zh_CN.ts \
    translations/harbour-todolist-sv.ts \
    translations/harbour-todolist-pl.ts \
    translations/harbour-todolist-no.ts \

CONFIG += c++11
include(libs/SortFilterProxyModel/SortFilterProxyModel.pri)

# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed
TARGET = harbour-todolist
CONFIG += sailfishapp

SOURCES += src/harbour-todolist.cpp
DISTFILES += qml/harbour-todolist.qml \
    qml/cover/CoverPage.qml \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/js/*.js \
    qml/constants/*.js \
    qml/constants/qmldir \
    qml/images/*.png \
    rpm/harbour-todolist.changes.in \
    rpm/harbour-todolist.changes.run.in \
    rpm/harbour-todolist.spec \
    rpm/harbour-todolist.yaml \
    translations/*.ts \
    harbour-todolist.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n

QML_IMPORT_PATH += qml/modules

# Note: version number is configured in yaml
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_RELEASE=\\\"$$RELEASE\\\"
include(libs/opal-cached-defines.pri)
