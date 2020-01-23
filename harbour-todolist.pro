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

# The name of your application
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

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-todolist-de.ts
