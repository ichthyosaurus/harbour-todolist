import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "constants" 1.0
import "js/storage.js" as Storage
import "js/helpers.js" as Helpers
import "pages"

ApplicationWindow
{
    id: main
    property alias rawModel: mainModel
    property alias categoriesModel: mainCategoriesModel
    property alias configuration: config

    property bool startupComplete: false
    property string currentCategoryName: ""

    property date today: Helpers.getDate(0)
    property date tomorrow: Helpers.getDate(1)

    property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'")
    property string timeFormat: qsTr("hh':'mm")
    property string fullDateFormat: qsTr("ddd d MMM yyyy")
    property string shortDateFormat: qsTr("d MMM yyyy")

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ListModel { id: mainModel }
    ListModel { id: mainCategoriesModel }

    ConfigurationGroup {
        id: config
        path: "/apps/harbour-todolist"
        property date lastCarriedOverFrom
        property date lastCarriedOverTo
        property int currentCategory
    }

    function addItem(forDate, task, description, entryState, subState, createdOn) {
        entryState = Storage.defaultFor(entryState, EntryState.todo);
        subState = Storage.defaultFor(subState, EntrySubState.today);
        createdOn = Storage.defaultFor(createdOn, forDate);
        var weight = 1;
        var interval = 0;
        var category = config.currentCategory;

        var entryId = Storage.addEntry(forDate, entryState, subState, createdOn,
                                       weight, interval, category, task, description);

        if (entryId === undefined) {
            console.error("failed to save new item", forDate, task);
            return;
        }

        rawModel.append({entryId: entryId, date: forDate, entryState: entryState,
                            subState: subState, createdOn: createdOn, weight: weight,
                            interval: interval, category: category,
                            text: task, description: description});
    }

    function updateItem(which, entryState, subState, text, description) {
        if (entryState !== undefined) rawModel.setProperty(which, "entryState", entryState);
        if (subState !== undefined) rawModel.setProperty(which, "subState", subState);
        if (text !== undefined) rawModel.setProperty(which, "text", text);
        if (description !== undefined) rawModel.setProperty(which, "description", description);

        var item = rawModel.get(which);
        Storage.updateEntry(item.entryId, item.date, item.entryState, item.subState,
                            item.createdOn, item.weight, item.interval,
                            item.category, item.text, item.description);
    }

    function deleteItem(which) {
        Storage.deleteEntry(rawModel.get(which).entryId);
        rawModel.remove(which);
    }

    function copyItemTo(which, copyToDate) {
        var item = rawModel.get(which);
        copyToDate = Storage.defaultFor(copyToDate, Helpers.getDate(1, item.date))
        addItem(copyToDate, item.text, item.description,
                EntryState.todo, EntrySubState.today, item.createdOn);
    }

    function addCategory(name, entryState) {
        entryState = Storage.defaultFor(entryState, EntryState.todo);
        name = Storage.defaultFor(name, "")
        var entryId = Storage.addCategory(name, entryState);

        if (entryId === undefined) {
            console.error("failed to save new category", name, entryState);
            return;
        } else {
            categoriesModel.append({entryId: entryId, entryState: entryState, name: name});
        }
    }

    function updateCategory(which, name, entryState) {
        if (name !== undefined) categoriesModel.setProperty(which, "name", name);
        if (entryState !== undefined) categoriesModel.setProperty(which, "entryState", entryState);
        var item = categoriesModel.get(which);
        Storage.updateCategory(item.entryId, item.name, item.entryState);
    }

    function deleteCategory(which) {
        Storage.deleteCategory(categoriesModel.get(which).entryId);
        categoriesModel.remove(which);
    }

    function setCurrentCategory(entryId) {
        entryId = Storage.defaultFor(entryId, 0);
        config.currentCategory = entryId;
        currentCategoryName = Storage.getCategory(config.currentCategory).name;

        if (currentCategoryName === undefined) {
            // if the requested category is not available, reset it to the default category
            setCurrentCategory(0);
        } else {
            startupComplete = false;
            rawModel.clear();
            var entries = Storage.getEntries(config.currentCategory);
            for (var i in entries) rawModel.append(entries[i]);
            startupComplete = true;
        }
    }

    Component.onCompleted: {
        if (Storage.carryOverFrom(config.lastCarriedOverFrom)) {
            config.lastCarriedOverTo = today;
            config.lastCarriedOverFrom = Helpers.getDate(-1, today);
        }
        setCurrentCategory(config.currentCategory);

        categoriesModel.clear();
        var categories = Storage.getCategories();
        for (var i in categories) categoriesModel.append(categories[i]);
    }
}
