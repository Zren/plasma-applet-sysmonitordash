import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

QtObject {
	id: lsblk
	property string updateCommand: "lsblk --output-all --json"
	property var value: ({}) // Empty Map

	function update() {
		execUtil.exec(updateCommand, commandDone)
	}

	function commandDone(cmd, exitCode, exitStatus, stdout, stderr) {
		// console.log('commandDone', exitCode, exitStatus, typeof exitCode)
		// console.log('\tstdout:', stdout)
		// console.log('\tstderr:', stderr)
		if (exitCode == 0) { // Sucess
			var newValue = JSON.parse(stdout)
			lsblk.value = newValue
		}
		updateDiskModel()
	}

	function updateDiskModel() {
		if (!(value && value.blockdevices))
			return;

		// Sort names so it's: [sda, sdb, ...]
		value.blockdevices.sort(function(a,b) {
			return a.name - b.name
		})
		
		var newDiskModel = []
		for (var i = 0; i < value.blockdevices.length; i++) {
			var blockDevice = value.blockdevices[i]
			if (blockDevice.type == "disk") {
				var newDisk = {}

				var diskLabel
				if (blockDevice.label) {
					diskLabel = i18nc("diskName diskLabel", "%1 (%2)", blockDevice.name, blockDevice.label)
				} else {
					diskLabel = '' + blockDevice.name
				}
				newDisk.label = i18n("Disk: %1", diskLabel)

				newDisk.sublabel = i18nc("diskModel sizeGb", "%1 %2", blockDevice.model, blockDevice.size)

				// "sda_(8:0)" (used by the systemmonitor datasource for disk i/o speed)
				newDisk.partitionId = blockDevice.name + "_(" + blockDevice['maj:min'] + ")"

				newDisk.partitionPaths = []
				if (blockDevice.children) {
					for (var j = 0; j < blockDevice.children.length; j++) {
						var deviceChild = blockDevice.children[j]

						if (deviceChild.fstype == "swap") {
							continue
						}

						if (deviceChild.mountpoint) {
							newDisk.partitionPaths.push(deviceChild.mountpoint)
						}
					}
				}

				newDiskModel.push(newDisk)
			}
		}

		// console.log("newDiskModel", JSON.stringify(newDiskModel, null, "\t"))
		config.diskModel = newDiskModel
	}

	property var hpSource: PlasmaCore.DataSource {
		id: hpSource
		engine: "hotplug"
		// connectedSources: sources
		interval: 0

		onSourceAdded: {
			// disconnectSource(source)
			// connectSource(source)
			// console.log('hotplug.onSourceAdded', source)
			// lsblk.update()
		}
		onSourceRemoved: {
			// disconnectSource(source)
			// console.log('hotplug.onSourceRemoved', source)
			// lsblk.update()
		}
	}

	Component.onCompleted: {
		update()
	}
}
