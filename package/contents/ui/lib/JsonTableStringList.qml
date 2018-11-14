import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

TableViewColumn {
	id: tableViewColumn

	movable: false

	property string placeholderText: ""

	delegate: JsonTableTextField {
		placeholderText: tableViewColumn.placeholderText

		function hasKey() {
			return (typeof tableView.model[styleData.row] !== "undefined"
				&& typeof tableView.model[styleData.row][tableViewColumn.role] !== "undefined"
			)
		}

		readonly property var cellValue: {
			if (hasKey()) {
				return tableView.model[styleData.row][tableViewColumn.role]
			} else {
				return ''
			}
		}
		function getter() {
			// console.log('StringList.getter', cellValue)
			return cellValue ? cellValue.join(',') : ''
		}

		function setterValue() {
			if (text) {
				return text.split(',')
			} else {
				if (hasKey()) {
					return []
				} else {
					return undefined
				}
			}
		}
	}
}
