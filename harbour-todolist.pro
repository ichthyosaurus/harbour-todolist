# This file is part of harbour-todolist.
# SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later

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

# Note: version number is configured in yaml
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_RELEASE=\\\"$$RELEASE\\\"
include(libs/opal-cached-defines.pri)

QML_IMPORT_PATH += qml/modules

SOURCES += \
    src/harbour-todolist.cpp \

DISTFILES += \
    qml/*.qml \
    qml/*/*.qml \
    qml/*/*.js \
    qml/*/*.py \
    rpm/harbour-*.changes \
    rpm/harbour-*.spec \
    rpm/harbour-*.yaml \
    translations/*.ts \
    harbour-*.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

CONFIG += c++11
include(libs/SortFilterProxyModel/SortFilterProxyModel.pri)

TRANSLATIONS += translations/harbour-todolist-*.ts
