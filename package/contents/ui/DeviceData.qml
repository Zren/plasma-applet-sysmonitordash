import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: deviceData

	readonly property string processorProduct: sdSource.data[processorUdi]['Product']


	// This might be a constant, but I can't guarantee it.
	readonly property string processorUdi: '/org/kde/solid/udev/sys/devices/system/cpu/cpu0'

	// You can debug SolidDevice with `solid-hardware list` and `solid-hardware details ...`
	PlasmaCore.DataSource {
		id: sdSource
		engine: "soliddevice"
		connectedSources: [
			processorUdi,
		]
		interval: 0

		// onSourceAdded: {
		// 	console.log('sdSource.onSourceAdded', source)
		// 	// disconnectSource(source)
		// 	// connectSource(source)
		// 	var propKeys = Object.keys(sdSource.data[processorUdi])
		// 	console.log(propKeys)
		// 	for (var i = 0; i < propKeys.length; i++) {
		// 		logProp(source, propKeys[i])
		// 	}
		// }
		// function logProp(udi, key) {
		// 	console.log(udi, key + ':\t', sdSource.data[udi][key])
		// }

		// onSourceRemoved: {
		// 	console.log('sdSource.onSourceRemoved', source)
		// 	// disconnectSource(source)
		// }

		// Component.onCompleted: console.log('sdSource.sources', sources)
	}
}
