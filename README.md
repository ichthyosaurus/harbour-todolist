# harbour-todolist

*for SailfishOS*

A simple to-do list manager for keeping track of what has to be done next.


**Features:**

- multiple projects
- recurring entries
- today's unfinished entries will be carried over for tomorrow
- four categories: today, tomorrow, this week, someday
- archive of all past entries


## Contributing

*Bug reports, and pull requests for translations, bug fixes, or new features are always welcome!*


### Translations

It would be wonderful if the app could be translated in as many languages as possible!

If you just found a typo, you can [open an issue](https://github.com/ichthyosaurus/harbour-todolist/issues/new).
Include the following details:

1. the language you were using
2. where you found the error
3. the wrong text
4. the correct translation


To add or update a translation, please follow these steps:

1. *If it did not exists before*, create a new catalog for your language by copying the
   base file [translations/harbour-todolist.ts](translations/harbour-todolist.ts).
   Then add the new translation to [harbour-todolist.pro](harbour-todolist.pro). You will
   find instructions at the top of the file.
2. Add yourself to the list of contributors in [qml/sf-about-page/about.js](qml/sf-about-page/about.js).
   You will find instructions in the file.
3. Translate the app's name in [harbour-todolist.desktop](harbour-todolist.desktop).
   You will find instructions in the file.
4. Translate everything else...

Please do not forget to translate the date formats to your local format. You can
find details on the available fields [in the Qt documentation](https://doc.qt.io/qt-5/qml-qtqml-date.html#details).
Also, if there is a (short) native term for "to-do list" in your language, please
translate the app's name.


### Other contributions

Please do not forget to add yourself to the list of contributors in
[qml/sf-about-page/about.js](qml/sf-about-page/about.js)!


## Development

Check-out this repository and update submodules:

    git clone https://github.com/ichthyosaurus/harbour-todolist.git todolist
    cd todolist
    git submodule update --init --recursive

Add the line `#include <QtQml>` at the top of the follow files:

    libs/SortFilterProxyModel/filters/filtersqmltypes.cpp
    libs/SortFilterProxyModel/sorters/sortersqmltypes.cpp

Open the project in the SailfishOS IDE, modify, build.


## License

Copyright (C) 2020  Mirian Margiani

`harbour-todolist` is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

`harbour-todolist` is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with `harbour-todolist`.  If not, see <http://www.gnu.org/licenses/>.

The source code is available [on Github](https://github.com/ichthyosaurus/harbour-todolist).


### Acknowledgements

`harbour-todolist` uses [SortFilterProxyModel](https://github.com/oKcerG/SortFilterProxyModel)
by Pierre-Yves Siret, released under the MIT License.
