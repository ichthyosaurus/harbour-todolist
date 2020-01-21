pragma Singleton
import QtQuick 2.0

QtObject {
    id: singleton

    property int todo: 0
    property int ignored: 1
    property int done: 2
}
