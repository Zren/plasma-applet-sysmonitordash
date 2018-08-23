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

	JsonTableView {
		id: tableView
		Layout.fillWidth: true
		Layout.fillHeight: true

		onCellChanged: {
			// textArea.valueObjChanged()
			textArea.jsonValue = JSON.stringify(textArea.valueObj, null, '  ')
			textArea.jsonValueChanged()
			plasmoid.configuration.sensorModel = textArea.jsonValue
			resizeColumnsToContents()
		}

		model: textArea.valueObj

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

	TextArea {
		id: textArea
		// visible: false
		Layout.fillWidth: true
		Layout.fillHeight: true
		property bool updateOnChange: true
		property string value: plasmoid.configuration.sensorModel

		property var valueObj: {
			try {
				return JSON.parse(value)
			} catch (err) {
				return ""
			}
		}
		property string jsonValue: JSON.stringify(valueObj, null, '  ')

		onJsonValueChanged: {
			text = JSON.stringify(valueObj, null, '  ')
		}

		text: jsonValue

	}
}
