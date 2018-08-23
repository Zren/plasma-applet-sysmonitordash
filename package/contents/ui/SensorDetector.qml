import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

QtObject {
	id: sensorDetector

	property var dataSource: PlasmaCore.DataSource {
		id: dataSource
		engine: "systemmonitor"

		connectedSources: []

		onSourceAdded: {
			// console.log('onSourceAdded', source)
			privateModel.append({
				name: source
			})
			debouncedSetModel.restart()
		}
	}

	property var privateModel: ListModel {
		id: privateModel
	}

	// Wait until we've finished populating before binding to the model.
	property var debouncedSetModel: Timer {
		id: debouncedSetModel
		interval: 400
		onTriggered: sensorDetector.model = sensorDetector.privateModel

	}

	property var model: []
}
