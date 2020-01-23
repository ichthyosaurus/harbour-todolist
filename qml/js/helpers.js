.pragma library

function getDate(offset, baseDate) {
    var currentDate = baseDate === undefined ? new Date() : baseDate;
    currentDate.setUTCDate(currentDate.getDate() + offset);
    currentDate.setUTCHours(0, 0, 0, 0);
    return currentDate;
}

function getDateString(date) {
    return new Date(date).toLocaleString(Qt.locale(), "yyyy-MM-dd");
}
