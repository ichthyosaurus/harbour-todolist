# harbour-todolist

*for SailfishOS*

A simple todo list manager for keeping track of what has to be done next.


**Features:**

- multiple projects
- recurring entries
- today's unfinished entries will be carried over for tomorrow
- four categories: today, tomorrow, this week, someday
- archive of all past entries


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
