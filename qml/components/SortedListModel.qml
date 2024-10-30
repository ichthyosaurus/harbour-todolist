/*
 * This file is part of harbour-todolist.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 *
 * Quick sort implementation based on
 * old code form harbour-expenditure:
 * SPDX-FileCopyrightText: 2022 Tobias Planitzer
 */

import QtQuick 2.6

ListModel {
    property string sortColumnName // required
    property string sortOrderResults: "desc"  // or "asc"

    function swap(a,b) {
        if (a<b) {
            move(a,b,1);
            move (b-1,a,1);
        } else if (a>b) {
            move(b,a,1);
            move (a-1,b,1);
        }
    }

    function partition(begin, end, pivot) {
        var piv=get(pivot)[sortColumnName];
        swap(pivot, end-1);
        var store=begin;
        var ix;
        for(ix=begin; ix<end-1; ++ix) {
            if (sortOrderResults === "asc"){
                if(get(ix)[sortColumnName] < piv) {
                    swap(store,ix);
                    ++store;
                }
            } else { // (sortOrderResults === "desc")
                if(get(ix)[sortColumnName] > piv) {
                    swap(store,ix);
                    ++store;
                }
            }
        }
        swap(end-1, store);
        return store;
    }

    function qsort(begin, end) {
        if(end-1>begin) {
            var pivot=begin+Math.floor(Math.random()*(end-begin));

            pivot=partition( begin, end, pivot);

            qsort(begin, pivot);
            qsort(pivot+1, end);
        }
    }

    function quick_sort(orderDirection) {
        sortOrderResults = orderDirection
        qsort(0,count)
    }

//    onCountChanged: {
//        quick_sort(sortOrderResults)
//    }
}
