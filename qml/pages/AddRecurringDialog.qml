import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"
import "../js/helpers.js" as Helpers

AddItemDialog {
    date: new Date(NaN)
    descriptionEnabled: true

    property bool enableStartDate: true
    property date startDate: main.today
    property int intervalDays: intervalCombo.currentItem.value
    property int defaultInterval: 1

    ComboBox {
        id: intervalCombo
        width: parent.width
        label: qsTr("Recurring")
        currentIndex: defaultInterval

        menu: ContextMenu {
            Repeater {
                model: 61
                delegate: MenuItem {
                    text: index === 0 ? qsTr("once", "interval for recurring entries")
                                      : qsTr("every %n day(s)", "interval for recurring entries", index)
                    property int value: index
                }
            }
        }
    }

    ValueButton {
        enabled: enableStartDate && intervalCombo.currentIndex !== 0
        label: qsTr("Starting at")
        value: startDate.toLocaleString(Qt.locale(), main.fullDateFormat)

        onClicked: {
            var dialog = pageStack.push(pickerComponent, { date: startDate })
            dialog.accepted.connect(function() {
                startDate = Helpers.getDate(0, dialog.date);
            })
        }

        Component {
            id: pickerComponent
            DatePickerDialog {}
        }
    }
}
