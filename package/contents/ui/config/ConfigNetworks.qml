import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."
import "../lib"

ConfigPage {

	signal configurationChanged()

	SensorDetector {
		id: sensorDetector

		property var networkSensorList: []

		onModelChanged: {
			var newNetworkList = []
			for (var i = 0; i < model.count; i++) {
				var sensor = model.get(i)
				var match = sensor.name.match(/^network\/interfaces\/(\w+)\//)
				if (match) {
					var networkName = match[1]
					if (newNetworkList.indexOf(networkName) === -1) {
						// Add if not seen before
						newNetworkList.push(networkName)
					}
				}
			}
			networkSensorList = newNetworkList
			networkSensorListChanged()
		}
	}

	Repeater {
		model: sensorDetector.networkSensorList

		CheckBox {
			readonly property string networkName: modelData
			readonly property bool ignoredByDefault: {
				// Keep this in sync with NetworkListDetector.qml
				return networkName == 'lo' // Ignore loopback device
					|| networkName.match(/^docker(\d+)/) // Ignore docker networks
					|| networkName.match(/^(tun|tap)(\d+)/) // Ingore tun/tap interfaces
			}

			text: networkName
			checked: plasmoid.configuration.ignoredNetworks.indexOf(networkName) == -1 && !ignoredByDefault
			enabled: !ignoredByDefault

			onClicked: {
				var ignoredNetworks = plasmoid.configuration.ignoredNetworks.slice(0) // copy()
				if (checked) {
					// Checking, and thus removing from the ignoredNetworks
					var i = ignoredNetworks.indexOf(networkName)
					ignoredNetworks.splice(i, 1)
					plasmoid.configuration.ignoredNetworks = ignoredNetworks
				} else {
					// Unchecking, and thus adding to the ignoredNetworks
					ignoredNetworks.push(networkName)
					plasmoid.configuration.ignoredNetworks = ignoredNetworks
				}
				// To modify a StringList we need to manually trigger configurationChanged.
				configurationChanged() 
			}
		}
	}
}
