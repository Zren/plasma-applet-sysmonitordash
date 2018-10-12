import QtQuick 2.0

QtObject {
	id: networkListDetector

	property Connections sensorConnection: Connections {
		target: sensorData
		onNetworkSensorListChanged: {
			networkListDetector.updateNetworkModel()
		}
	}

	function updateNetworkModel() {
		// [
		// 	{
		// 		"label": "Network",
		// 		"icon": "network-wired",
		// 		"interfaceName": "enp1s0"
		// 	},
		// 	{
		// 		"label": "WiFi",
		// 		"icon": "network-wireless",
		// 		"interfaceName": "wlp1s0"
		// 	}
		// ]
		var newNeworkModel = []
		for (var i = 0; i < sensorData.networkSensorList.length; i++) {
			var networkName = sensorData.networkSensorList[i]

			// SystemD network naming scheme:
			// https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
			// Eg: wlp5s6
			// First two letters are the hardware type.
			// p5 = Port 5
			// s6 = Slot 6

			if (networkName == 'lo' // Ignore loopback device
			  || networkName.match(/^docker(\d+)/) // Ignore docker networks
			) { 
				continue;
			}

			var newNetwork = {}
			newNetwork.interfaceName = networkName

			// First two letters are 
			if (networkName.match(/^wl/)) { // Wireless
				newNetwork.label = i18n("Wi-Fi")
				newNetwork.icon = "network-wireless"
			} else { // Eg: en (Ethernet)
				newNetwork.label = i18n("Network")
				newNetwork.icon = "network-wired"
			}
			newNeworkModel.push(newNetwork)
		}
		config.networkModel = newNeworkModel
	}
}

