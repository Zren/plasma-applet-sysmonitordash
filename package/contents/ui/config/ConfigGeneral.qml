import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."
import "../lib"

// ConfigPage {
// 	id: page
// 	showAppletVersion: true
ColumnLayout {

	SensorDetector {
		id: sensorDetector
	}

	QtObject {
		id: sensorModel
		readonly property string configValue: plasmoid.configuration.sensorModel
		readonly property var valueObj: {
			try {
				return JSON.parse(configValue)
			} catch (err) {
				return ""
			}
		}
		function getter() {
			try {
				return JSON.parse(plasmoid.configuration.sensorModel)
			} catch (err) {
				return ""
			}
		}
		// readonly property string jsonValue: JSON.stringify(valueObj, null, '  ')
	}

	JsonTableView {
		id: tableView
		Layout.fillWidth: true
		Layout.fillHeight: true

		onCellChanged: {
			sensorModel.valueObjChanged()
			var newValue = JSON.stringify(tableView.model, null, '  ')
			plasmoid.configuration.sensorModel = newValue

			resizeColumnsToContents()
		}

		Component.onCompleted: {
			tableView.model = sensorModel.getter()
			resizeColumnsToContents()
		}

		JsonTableString {
			role: "label"
			title: i18n("Label")
		}
		JsonTableString {
			role: "sublabel"
			title: i18n("SubLabel")
		}
		JsonTableSensor {
			role: "sensors"
			title: i18n("Sensor")
		}
		JsonTableStringList {
			role: "colors"
			title: i18n("Color")
		}
		JsonTableString {
			role: "icon"
			title: i18n("Icon")
		}
		JsonTableString {
			role: "units"
			title: i18n("Units")
		}
		JsonTableInt {
			role: "defaultMax"
			title: i18n("Max")
		}
	}
}
