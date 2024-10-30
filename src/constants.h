/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCL_HARBOUR_TODOLIST_H
#define INCL_HARBOUR_TODOLIST_H

#include "enumcontainer.h"

CREATE_ENUM(EntryState, Todo = 0, Ignored = 1, Done = 2)
CREATE_ENUM(EntrySubState, Today = 0, Tomorrow = 1, ThisWeek = 2, Someday = 3)

DECLARE_ENUM_REGISTRATION_FUNCTION(Todolist)

#ifdef __HACK_TO_FORCE_MOC
Q_OBJECT
#endif

#endif  // INCL_HARBOUR_TODOLIST_H
