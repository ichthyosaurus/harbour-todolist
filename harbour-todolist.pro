#
# This file is part of harbour-todolist.
# Copyright (C) 2020  Mirian Margiani
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

# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

include(libs/SortFilterProxyModel/SortFilterProxyModel.pri)

TARGET = harbour-todolist

CONFIG += sailfishapp c++11

SOURCES += src/harbour-todolist.cpp
DEFINES += VERSION_NUMBER=\\\"$$(VERSION_NUMBER)\\\"

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

DISTFILES += qml/sf-about-page/*.qml \
    qml/sf-about-page/license.html \
    qml/sf-about-page/about.js

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-todolist-en.ts \
    translations/harbour-todolist-de.ts \
    translations/harbour-todolist-zh_CN.ts
