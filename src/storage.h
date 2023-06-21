/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2023 Damien Caliste
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef STORAGE_H
#define STORAGE_H

#include <QObject>
#include <QQmlEngine>

#include <KCalendarCore/Todo>
#include <sqlitestorage.h>

class Entry
{
    Q_GADGET
    Q_PROPERTY(QString entryId READ entryId CONSTANT)
    Q_PROPERTY(QDateTime date READ date CONSTANT)
    Q_PROPERTY(QDateTime createdOn READ createdOn CONSTANT)
    Q_PROPERTY(State entryState READ entryState CONSTANT)
    Q_PROPERTY(DueTarget subState READ subState CONSTANT)
    Q_PROPERTY(int interval READ interval CONSTANT)
    Q_PROPERTY(QString text READ text CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(int project READ project CONSTANT)

 public:
    enum State {
        TODO,
        IGNORED,
        DONE
    };
    Q_ENUM(State)

    enum DueTarget {
        TODAY,
        TOMORROW,
        THIS_WEEK,
        SOMEDAY
    };
    Q_ENUM(DueTarget)

    Entry();
    Entry(const KCalendarCore::Todo::Ptr &todo, int projectId);
    ~Entry();

    QString entryId() const;
    QDateTime date() const;
    QDateTime createdOn() const;
    State entryState() const;
    DueTarget subState() const;
    int interval() const;
    QString text() const;
    QString description() const;
    int project() const;

 private:
    KCalendarCore::Todo::Ptr mTodo;
    int mProjectId;
};

Q_DECLARE_METATYPE(Entry)

class Project
{
    Q_GADGET
    Q_PROPERTY(int entryId READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(int entryState READ state CONSTANT)

 public:
    Project();
    Project(int projectId, const QString &name, int state);
    ~Project();

    int id() const;
    QString name() const;
    int state() const;

 private:
    int mId = 0;
    QString mName;
    int mState;
};

Q_DECLARE_METATYPE(Project)

class Storage: public QObject, public mKCal::ExtendedStorageObserver
{
    Q_OBJECT
    Q_PROPERTY(QVariantList projects READ getProjects NOTIFY projectsChanged)
    Q_PROPERTY(int currentProjectId READ currentProjectId WRITE setCurrentProjectId NOTIFY currentProjectChanged)
    Q_PROPERTY(Project currentProject READ currentProject NOTIFY currentProjectChanged)
    Q_PROPERTY(QVariantList entries READ getEntries NOTIFY entriesChanged)
    Q_PROPERTY(QVariantList archivedEntries READ getArchivedEntries NOTIFY entriesChanged)
    Q_PROPERTY(QVariantList recurringEntries READ getRecurrings NOTIFY entriesChanged)

 public:
    Storage(QObject *parent = nullptr);
    ~Storage();

    QVariantList getProjects() const;
    QVariantList getEntries() const;
    QVariantList getArchivedEntries() const;
    QVariantList getRecurrings() const;

    int currentProjectId() const;
    void setCurrentProjectId(int projectId);

    Project currentProject() const;

    Q_INVOKABLE QString addEntry(const QDateTime &forDate,
                                 Entry::State status,
                                 Entry::DueTarget subState,
                                 const QDateTime &createdOn,
                                 int weight,
                                 int interval,
                                 int project,
                                 const QString &task,
                                 const QString &description);
    Q_INVOKABLE void updateEntry(const QString &entryId,
                                 const QDateTime &forDate,
                                 Entry::State status,
                                 Entry::DueTarget subState,
                                 const QDateTime &createdOn,
                                 int weight,
                                 int interval,
                                 int project,
                                 const QString &task,
                                 const QString &description);
    Q_INVOKABLE void deleteEntry(const QString &entryId);

    Q_INVOKABLE QString addRecurring(const QDateTime &startDate,
                                     Entry::State status,
                                     int interval,
                                     int project,
                                     const QString &text,
                                     const QString &description);
    Q_INVOKABLE void updateRecurring(const QString &entryId,
                                     const QDateTime &startDate,
                                     Entry::State status,
                                     int interval,
                                     int project,
                                     const QString &text,
                                     const QString &description);
    Q_INVOKABLE void deleteRecurring(const QString &entryId);

    Q_INVOKABLE void carryOverFrom(const QDateTime &from);

    Q_INVOKABLE int addProject(const QString &name, Entry::State state);
    Q_INVOKABLE void updateProject(int projectId, const QString &name, Entry::State state);
    Q_INVOKABLE void deleteProject(int projectId);

    static Storage* appStorage(QQmlEngine *engine, QJSEngine *scriptEngine);

 signals:
    void projectsChanged();
    void currentProjectChanged();
    void entriesChanged();

 private:
    void storageModified(mKCal::ExtendedStorage *storage, const QString &info);
    void load();
    bool saveProject(const Project &project);
    mKCal::SqliteStorage mStorage;
    QHash<int, Project> mProjects;
    int mCurrentProjectId = 0;
};

#endif
