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

	Flow {
		Layout.fillWidth: true
		
		Button {
			iconName: "edit-table-insert-row-below"
			text: i18n("Add Sensor")
			onClicked: tableView.addRow()
		}
		Button {
			iconName: "edit-table-insert-row-below"
			text: i18n("Add Temps")
			onClicked: tableView.addAllTemps()
		}
		Button {
			iconName: "edit-table-insert-row-below"
			text: i18n("Add Fans")
			onClicked: tableView.addAllFans()
		}
		Button {
			iconName: "edit-table-insert-row-below"
			text: i18n("Add all lm_sensors")
			onClicked: tableView.addAllLmSensors()
		}
	}

	JsonTableView {
		id: tableView
		Layout.fillWidth: true
		Layout.fillHeight: true

		function updateConfigValue() {
			sensorModel.valueObjChanged()
			var newValue = JSON.stringify(tableView.model, null, '  ')
			plasmoid.configuration.sensorModel = newValue
		}

		function indexOfSensor(sensorName) {
			for (var rowIndex = 0; rowIndex < tableView.model.length; rowIndex++) {
				var row = tableView.model[rowIndex]
				if (typeof row.sensors !== "undefined") {
					for (var i = 0; i < row.sensors.length; i++) {
						if (row.sensors[i] == sensorName) {
							return rowIndex
						}
					}
				}
			}
			return -1
		}

		function hasRowWithSensor(sensorName) {
			return indexOfSensor(sensorName) >= 0
		}

		function addAllSensors(predicate) {
			var rowAdded = false
			var sensors = sensorDetector.model
			for (var i = 0; i < sensors.count; i++) {
				var sensor = sensors.get(i)
				var shouldAdd = predicate(sensor.name)
				if (shouldAdd) {
					console.log('sensorAdded', i, sensor.name)
					var newLength = tableView.model.push({
						sensors: [sensor.name]
					})
					var newIndex = newLength - 1
					console.log('\t', newIndex, JSON.stringify(tableView.model[newIndex]))
					// tableView.rowAdded(newIndex) // it only calls updateConfigValue()
					rowAdded = true
				}
			}
			if (rowAdded) {
				tableView.modelChanged()
				updateConfigValue()
			}
		}

		function addAllRegex(regex) {
			tableView.addAllSensors(function(sensorName){
				return sensorName.match(regex)
					&& !tableView.hasRowWithSensor(sensorName)
			})
		}

		function addAllTemps() {
			tableView.addAllRegex(/^lmsensors\/.+\/temp\d+$/)
		}
		
		function addAllFans() {
			tableView.addAllRegex(/^lmsensors\/.+\/fan\d+$/)
		}

		function addAllLmSensors() {
			tableView.addAllRegex(/^lmsensors\//)
		}

		onCellChanged: {
			updateConfigValue()
			resizeColumnsToContents()
		}
		onRowAdded: updateConfigValue()
		onRowRemoved: updateConfigValue()

		Component.onCompleted: {
			tableView.model = sensorModel.getter()
			resizeColumnsToContents()
		}

		TableViewColumn {
			delegate: Button {
				iconName: "delete"
				onClicked: tableView.removeRow(styleData.row)
			}
		}

		JsonTableSensor {
			role: "sensors"
			title: i18n("Sensor")
		}
		JsonTableString {
			role: "label"
			title: i18n("Label")
		}
		JsonTableString {
			role: "sublabel"
			title: i18n("SubLabel")
		}
		JsonTableStringList {
			role: "colors"
			title: i18n("Color")
			placeholderText: "#000000"
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
			title: i18n("MaxY")
		}
	}
}
