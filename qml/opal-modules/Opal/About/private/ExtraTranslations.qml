/*
 * This file is part of opal-about.
 * Copyright (C) 2021  Mirian Margiani
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * This file should not be used anywhere. It contains a list of some commonly
 * needed strings for which Opal.About will provide default translations.
 * Do not include this file in qmldir.
 *
 */

Item {
    // commonly used strings
    readonly property string a: qsTranslate("Opal.About.i18n", "Development")
    readonly property string b: qsTranslate("Opal.About.i18n", "Programming")
    readonly property string c: qsTranslate("Opal.About.i18n", "Translations")
    readonly property string c: qsTranslate("Opal.About.i18n", "Icon Design")
    readonly property string d: qsTranslate("Opal.About.i18n", "Third party libraries")

    // some languages (to be expanded!)
    readonly property string lb: qsTranslate("Opal.About.i18n", "Swedish")
    readonly property string la: qsTranslate("Opal.About.i18n", "Polish")
    readonly property string ld: qsTranslate("Opal.About.i18n", "German")
    readonly property string ld: qsTranslate("Opal.About.i18n", "French")
    readonly property string lc: qsTranslate("Opal.About.i18n", "Chinese")
    readonly property string le: qsTranslate("Opal.About.i18n", "English")
    readonly property string le: qsTranslate("Opal.About.i18n", "Italian")
    readonly property string le: qsTranslate("Opal.About.i18n", "Finnish")
    readonly property string le: qsTranslate("Opal.About.i18n", "Norwegian")
}
