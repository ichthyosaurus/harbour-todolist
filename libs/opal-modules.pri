#
# This file is part of Opal and has been released into the public domain.
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2021 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/master/snippets/opal-use-modules.md
# for up-to-date documentation.
#
# Include this file in your main PRO file and add the modules you want to use to
# the CONFIG variable.
#
# Copy the module packages to the path defined in OPAL_PATH which must be below
# your app's main qml directory.
#
# Make sure to disable "RPM provides" in the spec file by adding the following
# in the "# >> macros" section:
#       %define __provides_exclude_from ^%{_datadir}/.*$
# See https://harbour.jolla.com/faq#2.6.0 for more information.

OPAL_PATH = qml/opal-modules
QML_IMPORT_PATH += $$OPAL_PATH
OPAL_TR_PATH = libs/opal-translations

# activate with: CONFIG += opal-about
opal-about {
    DISTFILES += \
        $$OPAL_PATH/Opal/About/*.qml \
        $$OPAL_PATH/Opal/About/qmldir \
        $$OPAL_PATH/Opal/About/private/*.qml \
        $$OPAL_PATH/Opal/About/private/qmldir
}

lupdate_only {
    TR_EXCLUDE += $$OPAL_PATH
    TRANSLATIONS += $$OPAL_TR_PATH/*.ts
}
