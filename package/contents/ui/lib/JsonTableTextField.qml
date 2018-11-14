import QtQuick 2.4
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

TextField {
	id: textField

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
		return cellValue || ''
	}
	function setterValue() {
		return text
	}

	text: getter()
	onTextChanged: {
		tableView.model[styleData.row][tableViewColumn.role] = setterValue()
		tableView.cellChanged(styleData.row, styleData.column, tableViewColumn.role)
	}
	onFocusChanged: {
		if (focus) {
			// tableView.selection.clear()
			// tableView.selection.select(styleData.row, styleData.row)
		}
	}

	TextMetrics {
		id: textMetrics
		font: textField.font
		text: textField.displayText
	}
	property int stylePadding: 8 // Guestimate
	implicitWidth: textMetrics.advanceWidth + (stylePadding * 2)
}
