/*
 * This file is part of harbour-todolist.
 * SPDX-FileCopyrightText: 2023 Damien Caliste
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "storage.h"

#include <QStandardPaths>
#include <QDir>
#include <QDebug>

#include <KCalendarCore/CalFilter>

Entry::Entry()
{
}

Entry::Entry(const KCalendarCore::Todo::Ptr &todo, int projectId)
    : mTodo(todo)
    , mProjectId(projectId)
{
}

Entry::~Entry()
{
}

QString Entry::entryId() const
{
    return mTodo ? mTodo->uid() : QString();
}

QDateTime Entry::date() const
{
    switch (subState()) {
    case 0:
        return QDateTime(QDate::currentDate());
    case 1:
        return QDateTime(QDate::currentDate()).addDays(1);
    case 2:
        return QDateTime(QDate(8888,1,1), QTime(), Qt::LocalTime);
    default:
        return mTodo && mTodo->hasDueDate() ? mTodo->dtDue() : QDateTime(QDate(9999,1,1), QTime(), Qt::LocalTime);
    }
}

QDateTime Entry::createdOn() const
{
    return mTodo ? mTodo->dtStart() : QDateTime();
}

Entry::State Entry::entryState() const
{
    if (mTodo && mTodo->status() == KCalendarCore::Incidence::StatusCanceled) {
        return IGNORED;
    } else if (mTodo && mTodo->status() == KCalendarCore::Incidence::StatusCompleted) {
        return DONE;
    } else {
        return TODO;
    }
}

Entry::DueTarget Entry::subState() const
{
    const QDate today = QDate::currentDate();
    if (mTodo && mTodo->hasDueDate()
               && (mTodo->dtDue().date() == today
                   || (mTodo->recurs() && mTodo->recurrence()->recursOn(today, QTimeZone::systemTimeZone())))) {
        return TODAY;
    } else if (mTodo && mTodo->hasDueDate()
               && (mTodo->dtDue().date().addDays(-1) == today
                   || (mTodo->recurs() && mTodo->recurrence()->recursOn(today.addDays(1), QTimeZone::systemTimeZone())))) {
        return TOMORROW;
    } else if (mTodo && mTodo->hasDueDate()
               && mTodo->dtDue().date().dayOfWeek() == 7) {
        return THIS_WEEK;
    } else {
        return SOMEDAY;
    }
}

int Entry::interval() const
{
    return mTodo && mTodo->recurs()
        && mTodo->recurrence()->recurrenceType() == KCalendarCore::Recurrence::rDaily
        ? mTodo->recurrence()->frequency() : 0;
}

QString Entry::text() const
{
    return mTodo ? mTodo->summary() : QString();
}

QString Entry::description() const
{
    return mTodo ? mTodo->description() : QString();
}

int Entry::project() const
{
    return mProjectId;
}

Project::Project()
{
}

Project::Project(int projectId, const QString &name, int state)
    : mId(projectId)
    , mName(name)
    , mState(state)
{
}

Project::~Project()
{
}

int Project::id() const
{
    return mId;
}

QString Project::name() const
{
    return mName;
}

int Project::state() const
{
    return mState;
}

Storage::Storage(QObject *parent)
    : QObject(parent)
    , mStorage(mKCal::ExtendedCalendar::Ptr(new mKCal::ExtendedCalendar(QTimeZone::systemTimeZone())),
               QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).filePath(QString::fromLatin1("db")))
{
    if (!QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation))
        || !mStorage.open()) {
        qWarning() << "Unable to open storage at path" << mStorage.databaseName();
    }

    KCalendarCore::CalFilter *filter = new KCalendarCore::CalFilter;
    filter->setEnabled(true);
    filter->setCriteria(KCalendarCore::CalFilter::ShowCategories);
    mStorage.calendar()->setFilter(filter);

    load();
}

Storage::~Storage()
{
}

#define DEFAULT_ID 1
void Storage::load()
{
    if (!mStorage.load()) {
        qWarning() << "Unable to reload todos";
    }

    const mKCal::Notebook::Ptr notebook = mStorage.defaultNotebook();
    mProjects.clear();
    for (const QByteArray &key : notebook->customPropertyKeys()) {
        
        if (key.startsWith("PROJECT_") && key.endsWith("_NAME")) {
            bool ok;
            QByteArray idStr = key.mid(8);
            idStr.chop(5);
            int id = idStr.toInt(&ok);
            if (ok) {
                const QString name = notebook->customProperty(key);
                int state = notebook->customProperty(QByteArray("PROJECT_") + QByteArray::number(id) + QByteArray("_STATE")).toInt(&ok);
                if (!ok)
                    state = 0;
                mProjects.insert(id, Project(id, name, state));
            }
        }
    }
    if (!mProjects.contains(DEFAULT_ID)) {
        mProjects.insert(DEFAULT_ID, Project(DEFAULT_ID, "Default", 0));
    }
}

void Storage::storageModified(mKCal::ExtendedStorage *storage, const QString &info)
{
    Q_UNUSED(storage);
    Q_UNUSED(info);

    load();
    emit projectsChanged();
    emit entriesChanged();
}

Storage* Storage::appStorage(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine);

    return new Storage(engine);
}

QVariantList Storage::getEntries() const
{
    const QDate today = QDate::currentDate();
    const QString project = mProjects.value(mCurrentProjectId).name();
    mStorage.calendar()->filter()->setCategoryList(QStringList() << project);

    QVariantList list;
    for (const KCalendarCore::Todo::Ptr &todo : mStorage.calendar()->todos()) {
        if (!todo->hasDueDate() || todo->dtDue().date() >= today
            || (todo->recurs() && todo->status() == KCalendarCore::Incidence::StatusNone)) {
            list.append(QVariant::fromValue(Entry(todo, mCurrentProjectId)));
        }
    }
    return list;
}

QVariantList Storage::getArchivedEntries() const
{
    const QDate today = QDate::currentDate();
    const QString project = mProjects.value(mCurrentProjectId).name();
    mStorage.calendar()->filter()->setCategoryList(QStringList() << project);

    QVariantList list;
    for (const KCalendarCore::Todo::Ptr &todo : mStorage.calendar()->todos()) {
        if (todo->hasDueDate() && todo->dtDue().date() < today && !todo->recurs()) {
            list.append(QVariant::fromValue(Entry(todo, mCurrentProjectId)));
        }
    }
    return list;
}

QVariantList Storage::getRecurrings() const
{
    const QString project = mProjects.value(mCurrentProjectId).name();
    mStorage.calendar()->filter()->setCategoryList(QStringList() << project);

    QVariantList list;
    for (const KCalendarCore::Todo::Ptr &todo : mStorage.calendar()->todos()) {
        if (todo->recurs() || todo->hasRecurrenceId()) {
            list.append(QVariant::fromValue(Entry(todo, mCurrentProjectId)));
        }
    }
    return list;
}

static QDateTime fromMagicDt(const QDateTime &dt)
{
    if (dt.date() == QDate(8888, 1, 1)) {
        // End of the week
        const QDate due = QDate::currentDate();
        return QDateTime(due.addDays(7 - due.dayOfWeek()));
    } else if (dt.date() == QDate(9999, 1, 1)) {
        // Someday
        return QDateTime();
    } else {
        return dt;
    }
}

static void setTodo(KCalendarCore::Todo::Ptr todo,
                    const QDateTime &forDate,
                    Entry::State status,
                    const QDateTime &createdOn,
                    const QString &project,
                    const QString &task,
                    const QString &description,
                    int interval = 0)
{
    todo->setDtDue(fromMagicDt(forDate));
    todo->setDtStart(fromMagicDt(createdOn));
    if (status == Entry::TODO) {
        todo->setStatus(KCalendarCore::Incidence::StatusNone);
    } else if (status == Entry::IGNORED) {
        todo->setStatus(KCalendarCore::Incidence::StatusCanceled);
    } else if (status == Entry::DONE) {
        todo->setStatus(KCalendarCore::Incidence::StatusCompleted);
    }
    if (!project.isEmpty()) {
        todo->setCategories(QStringList() << project);
    } else {
        todo->setCategories(QStringList());
    }
    todo->setSummary(task);
    todo->setDescription(description);
    if (interval > 0) {
        todo->recurrence()->setDaily(interval);
    }
}

QString Storage::addEntry(const QDateTime &forDate,
                          Entry::State status,
                          Entry::DueTarget subState,
                          const QDateTime &createdOn,
                          int weight,
                          int interval,
                          int project,
                          const QString &task,
                          const QString &description)
{
    Q_UNUSED(subState);
    Q_UNUSED(weight);
    Q_UNUSED(interval);

    const QString projectStr = mProjects.value(project).name();
    KCalendarCore::Todo::Ptr todo(new KCalendarCore::Todo);
    setTodo(todo, forDate, status, createdOn, projectStr, task, description);
    mStorage.calendar()->addTodo(todo);
    if (!mStorage.save()) {
        qWarning() << "Unable to save todo" << task;
        return QString();
    }
    return todo->uid();
}

void Storage::updateEntry(const QString &entryId,
                          const QDateTime &forDate,
                          Entry::State status,
                          Entry::DueTarget subState,
                          const QDateTime &createdOn,
                          int weight,
                          int interval,
                          int project,
                          const QString &task,
                          const QString &description)
{
    Q_UNUSED(subState);
    Q_UNUSED(weight);
    Q_UNUSED(interval);

    const QString projectStr = mProjects.value(project).name();
    KCalendarCore::Todo::Ptr todo = mStorage.calendar()->todo(entryId);
    if (!todo) {
        qWarning() << "unable to find todo" << entryId;
        return;
    }
    todo->startUpdates();
    setTodo(todo, forDate, status, createdOn, projectStr, task, description);
    todo->endUpdates();
    if (!mStorage.save()) {
        qWarning() << "Unable to update todo" << task;
    }
}

void Storage::deleteEntry(const QString &entryId)
{
    KCalendarCore::Todo::Ptr todo = mStorage.calendar()->todo(entryId);
    if (!todo) {
        qWarning() << "unable to find todo" << entryId;
        return;
    }
    mStorage.calendar()->deleteTodo(todo);
    if (!mStorage.save()) {
        qWarning() << "Unable to delete todo" << todo->summary();
    }
}

QString Storage::addRecurring(const QDateTime &startDate,
                              Entry::State status,
                              int interval,
                              int project,
                              const QString &text,
                              const QString &description)
{
    const QString projectStr = mProjects.value(project).name();
    KCalendarCore::Todo::Ptr todo(new KCalendarCore::Todo);
    setTodo(todo, startDate, status, startDate, projectStr, text, description, interval);
    mStorage.calendar()->addTodo(todo);
    if (!mStorage.save()) {
        qWarning() << "Unable to save recurring todo" << text;
        return QString();
    }
    emit entriesChanged();
    return todo->uid();
}

void Storage::updateRecurring(const QString &entryId,
                              const QDateTime &startDate,
                              Entry::State status,
                              int interval,
                              int project,
                              const QString &text,
                              const QString &description)
{
    const QString projectStr = mProjects.value(project).name();
    KCalendarCore::Todo::Ptr todo = mStorage.calendar()->todo(entryId);
    if (!todo) {
        qWarning() << "unable to find todo" << entryId;
        return;
    }
    todo->startUpdates();
    setTodo(todo, startDate, status, startDate, projectStr, text, description, interval);
    todo->endUpdates();
    if (!mStorage.save()) {
        qWarning() << "Unable to update todo" << text;
    }
    emit entriesChanged();
}

void Storage::deleteRecurring(const QString &entryId)
{
    deleteEntry(entryId);
    emit entriesChanged();
}

void Storage::carryOverFrom(const QDateTime &from)
{
    const QDate today = QDate::currentDate();
    for (const KCalendarCore::Todo::Ptr &todo : mStorage.calendar()->rawTodos()) {
        if (todo->hasDueDate()
            && !todo->recurs()
            && todo->dtDue().date() < today && todo->dtDue().date() >= from.date()
            && todo->status() == KCalendarCore::Incidence::StatusNone) {
            todo->setDtDue(QDateTime(today));
        }
    }
    if (!mStorage.save()) {
        qWarning() << "Unable to carry todo over from" << from;
    }
}

QVariantList Storage::getProjects() const
{
    QVariantList list;
    for (const Project &project : mProjects) {
        list.append(QVariant::fromValue(project));
    }
    return list;
}

int Storage::currentProjectId() const
{
    return mCurrentProjectId;
}

void Storage::setCurrentProjectId(int projectId)
{
    if (!mProjects.contains(projectId)) {
        qWarning() << "wrong projectId" << projectId;
        projectId = DEFAULT_ID;
    }
    if (mCurrentProjectId == projectId) {
        return;
    }
    mCurrentProjectId = projectId;
    emit currentProjectChanged();
    emit entriesChanged();
}

Project Storage::currentProject() const
{
    return mProjects.value(mCurrentProjectId);
}

bool Storage::saveProject(const Project &project)
{
    mKCal::Notebook::Ptr notebook = mStorage.defaultNotebook();
    const QByteArray key = QByteArray("PROJECT_") + QByteArray::number(project.id());
    notebook->setCustomProperty(key + QByteArray("_NAME"), project.name());
    notebook->setCustomProperty(key + QByteArray("_STATE"),
                                project.state() < 0 ? QString() : QString::number(project.state()));
    return mStorage.updateNotebook(notebook);
}

int Storage::addProject(const QString &name, Entry::State state)
{
    int projectId = 0;
    for (int id : mProjects.keys()) {
        if (id > projectId)
            projectId = id;
    }
    projectId += 1;

    const Project project(projectId, name, state);
    if (!saveProject(project)) {
        qWarning() << "Unable to add project" << name << projectId;
        return -1;
    }
    mProjects.insert(projectId, project);
    return projectId;
}

void Storage::updateProject(int projectId, const QString &name, Entry::State state)
{
    const Project project(projectId, name, state);
    if (!saveProject(project)) {
        qWarning() << "Unable to update project" << name << projectId;
        return;
    }

    if (!mProjects.contains(projectId)) {
        qWarning() << "Unable to update project" << name << projectId;
        return;
    }
    const QString &oldName = mProjects[projectId].name();
    mStorage.calendar()->filter()->setCategoryList(QStringList() << oldName);
    for (const KCalendarCore::Todo::Ptr &todo : mStorage.calendar()->todos()) {
        QStringList categories = todo->categories();
        categories.removeAll(oldName);
        categories << name;
        todo->setCategories(categories);
    }
    if (!mStorage.save()) {
        qWarning() << "Unable to upadte todos for project" << name << projectId;
        return;
    }
    mProjects.insert(projectId, Project(projectId, name, state));
    emit projectsChanged();
    if (projectId == mCurrentProjectId) {
        emit currentProjectChanged();
    }
}

void Storage::deleteProject(int projectId)
{
    if (projectId == 1) {
        qWarning() << "Cannot delete the default project";
        return;
    }

    const Project project(projectId, QString(), -1);
    if (!saveProject(project)) {
        qWarning() << "Unable to delete project" << projectId;
        return;
    }

    if (!mProjects.contains(projectId)) {
        qWarning() << "Unable to delete project" << projectId;
        return;
    }
    mStorage.calendar()->filter()->setCategoryList(QStringList() << mProjects[projectId].name());
    for (const KCalendarCore::Todo::Ptr &todo : mStorage.calendar()->todos()) {
        mStorage.calendar()->deleteTodo(todo);
    }
    if (!mStorage.save()) {
        qWarning() << "Unable to delete todos of project" << projectId;
        return;
    }
    mProjects.remove(projectId);
    emit projectsChanged();
}
