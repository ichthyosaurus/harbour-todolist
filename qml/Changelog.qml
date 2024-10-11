/*
 * This file is part of harbour-todolist.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: Mirian Margiani
 */

import QtQuick 2.0
import "modules/Opal/About"

ChangelogList {
    ChangelogItem {
        version: "1.3.0-1"
        date: "2024-10-11"
        paragraphs: [
            "- This is mainly a maintenance release to bring the app back into shape for future development<br>" +
            "- Updated translations: Swedish, Norwegian, Russian, Polish,<br>" +
            "- Added support page for donating and contributing<br>" +
            "- Dropped all Sailjail permissions<br>" +
            "- Fixed changing the state of recurring entries<br>" +
            "- Fixed pages so that all screen orientations are allowed now<br>" +
            "- Fixed app details on about page<br>" +
            "- Updated translator credits (now directly from Weblate)<br>" +
            "- Updated packaging and did lots of general maintenance"
        ]
    }
    ChangelogItem {
        version: "1.2.0-1"
        date: "2022-03-24"
        paragraphs: [
            "- all translations updated with a few strings fixed and clarified<br>" +
            "- added translations: Norwegian<br>" +
            "- updated translations: Polish<br>" +
            "- fixed marking and moving entries<br>" +
            "- added a new Sailjail profile (\"Documents\" permission required for import and export)<br>" +
            "- added support for My Backup<br>" +
            "- added an option to move entries to another project when editing<br>" +
            "- added a new \"About\" page using Opal.About<br>" +
            "- reduced package size by shrinking icon files<br>" +
            "- improved licensing: the project is now 'reuse'-compliant (cf. https://reuse.software/spec/)<br>" +
            "- new known bug: marking recurring entries as \"done\" is not possible"
        ]
    }
    ChangelogItem {
        version: "1.1.4-1"
        date: "2020-12-21"
        paragraphs: [
            "- Update Swedish translation by eson57 (thank you!)"
        ]
    }
    ChangelogItem {
        version: "1.1.3-1"
        date: "2020-12-19"
        paragraphs: [
            "- Fix some tiny typos<br>" +
            "- Rebuild with latest SDK and add i486 target"
        ]
    }
    ChangelogItem {
        version: "1.1.2-1"
        date: "2020-05-09"
        paragraphs: [
            "- Add Polish (pl) translation by atlochowski (thank you!)<br>" +
            "- Fix a typo in the app's name<br>" +
            "- Improve documentation on Github"
        ]
    }
    ChangelogItem {
        version: "1.1.1-1"
        date: "2020-05-08"
        paragraphs: [
            "- Fix new recurring entries not being copied when they are due<br>" +
            "- Do not copy recurring entries that start in the future<br>" +
            "- Make sure new recurring entries are directly added for 'today' if necessary"
        ]
    }
    ChangelogItem {
        version: "1.1.0-1"
        date: "2020-05-07"
        paragraphs: [
            "- Contributions by CoanTeen (thank you!)<br>" +
            "    - Add support for keeping the app always opened<br>" +
            "    - Fix the planning date selection when added from cover page<br>" +
            "    - Use the local time to zero hour and minutes<br>" +
            "    - Do not duplicate section headers for entries from the database<br>" +
            "- Update Chinese (zh_CN) translation by dashinfantry (thank you!)<br>" +
            "- Fix \"continue today\" for archived entries<br>" +
            "- Update contributors page<br>" +
            "- Pre-select last selected category when adding from cover page<br>" +
            "- Reset last selected category to 'today' when switching projects"
        ]
    }
    ChangelogItem {
        version: "1.0.2-1"
        date: "2020-04-24"
        paragraphs: [
            "- Add Swedish (sv) translation by eson57 (thank you!)"
        ]
    }
    ChangelogItem {
        version: "1.0.1-1"
        date: "2020-04-22"
        paragraphs: [
            "- Move \"About\" and \"Show old entries\" to the top pulley menu<br>" +
            "- Reduce visual glitching when quickly scrolling down a long list while the last section is closed<br>" +
            "- Fix section open state being unreliably reset when changing project<br>" +
            "- Only load archived entries when they are needed<br>" +
            "- Add Chinese (zh_CN) translation by dashinfantry (thank you!)"
        ]
    }
    ChangelogItem {
        version: "1.0.0-1"
        date: "2020-04-19"
        paragraphs: [
            "- Initial public release"
        ]
    }
}
