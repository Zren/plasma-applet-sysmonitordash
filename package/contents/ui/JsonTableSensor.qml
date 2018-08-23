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

		implicitWidth: 200 * units.devicePixelRatio

		function selectCurrentItem() {
			if (styleData.value && styleData.value.length >= 1) {
				var i = comboBox.find(styleData.value[0])
				if (i >= 0) {
					comboBox.currentIndex = i
				}
			}
		}

		Component.onCompleted: selectCurrentItem()
		onModelChanged: selectCurrentItem()

		onCurrentIndexChanged: {
			if (currentIndex <= 0) {
				return // skip
			} else if (styleData.value && styleData.value.length >= 1 && currentText == styleData.value[0]) {
				return // skip
			} else {
				tableView.model[styleData.row][tableViewColumn.role] = [currentText]
				tableView.cellChanged(styleData.row, styleData.column, tableViewColumn.role)
			}
		}
	}
}
