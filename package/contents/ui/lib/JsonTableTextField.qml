import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

TextField {
	function getter() {
		return (styleData.value || '')
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
			tableView.selection.clear()
			tableView.selection.select(styleData.row, styleData.row)
		}
	}
}
