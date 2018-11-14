import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

TableViewColumn {
	id: tableViewColumn

	movable: false

	delegate: ComboBox {
		id: comboBox
		model: sensorDetector.model
		textRole: 'name'

		function hasKey() {
			return (typeof tableView.model[styleData.row] !== "undefined"
				&& typeof tableView.model[styleData.row][tableViewColumn.role] !== "undefined"
			)
		}

		readonly property var cellValue: {
			// console.log('Sensor.cellValue', hasKey(), tableView.model[styleData.row][tableViewColumn.role])
			if (hasKey()) {
				return tableView.model[styleData.row][tableViewColumn.role]
			} else {
				return []
			}
		}

		implicitWidth: 300 * units.devicePixelRatio

		function selectCurrentItem() {
			if (count > 0 && cellValue && cellValue.length >= 1) {
				var i = comboBox.find(cellValue[0])
				if (i >= 0) {
					comboBox.currentIndex = i
				}
			}
		}

		// Note: sensorDetector.model is not populated during Component.onCompleted
		// Note: sensorDetector.modelChanged is fired with an empty list []
		onModelChanged: {
			// console.log('sensorDetector.onModelChanged', sensorDetector.model)
			selectCurrentItem()
		}
		Component.onCompleted: {
			// console.log('ComboBox.onCompleted', sensorDetector.model)
			selectCurrentItem()
		}
		onCellValueChanged: {
			// console.log('ComboBox.onCellValueChanged', cellValue)
			selectCurrentItem()
		}

		onCurrentIndexChanged: {
			if (currentIndex <= 0) {
				return // skip
			} else if (cellValue && cellValue.length >= 1 && currentText == cellValue[0]) {
				return // skip
			} else {
				tableView.model[styleData.row][tableViewColumn.role] = [currentText]
				tableView.cellChanged(styleData.row, styleData.column, tableViewColumn.role)
			}
		}
	}
}
