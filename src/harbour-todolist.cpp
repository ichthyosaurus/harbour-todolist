/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2020-2022 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

//#ifdef QT_QML_DEBUG
#include <QtQuick>
//#endif

#include <sailfishapp.h>
#include "requires_defines.h"

#include "storage.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName("harbour-todolist"); // needed for Sailjail
    app->setApplicationName("harbour-todolist");

    qmlRegisterType<Storage>("Harbour.Todolist", 1, 0, "Storage");
    qRegisterMetaType<KCalendarCore::Incidence::Status>();
    qRegisterMetaType<Entry>();
    qRegisterMetaType<Entry::State>();
    qRegisterMetaType<Entry::DueTarget>();
    qmlRegisterUncreatableType<Entry>("Harbour.Todolist", 1, 0, "Entry", "Use Storage singleton to read or create entries.");
    qRegisterMetaType<Project>();
    qmlRegisterUncreatableType<Project>("Harbour.Todolist", 1, 0, "Project", "Use Storage singleton to read or create projects.");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("APP_VERSION", QString(APP_VERSION));
    view->rootContext()->setContextProperty("APP_RELEASE", QString(APP_RELEASE));
    view->engine()->addImportPath(SailfishApp::pathTo("qml/modules").toString());
    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
