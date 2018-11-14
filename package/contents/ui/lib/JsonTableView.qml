// Version 2

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

TableView {
	id: tableView
	signal cellChanged(int row, int cell, string role)
	signal rowAdded(int indexAdded)
	signal rowRemoved(int indexRemoved)


	function addRow(obj) {
		if (typeof obj === "undefined") {
			obj = {}
		}
		var newLength = tableView.model.push(obj)
		var newIndex = newLength - 1
		rowAdded(newIndex)
		tableView.modelChanged()
	}

	function removeRow(rowIndex) {
		tableView.model.splice(rowIndex, 1)
		rowRemoved(rowIndex)
		tableView.modelChanged()
	}
}
