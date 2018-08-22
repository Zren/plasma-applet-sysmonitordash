import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

RowLayout {
	id: diskUsageBar
	Layout.fillWidth: true
	Layout.preferredHeight: Screen.height / 100

	property var partitionPaths: []
	Repeater {
		id: repeater
		model: partitionPaths

		PartitionUsageBar {
			partitionPath: modelData
			onTotalspaceChanged: diskUsageBar.updateDiskSize()

			Layout.minimumWidth: Screen.height / 100
		}
	}

	property double totalspace: 0
	function updateDiskSize() {
		var diskTotalspace = 0
		for (var i = 0; i < repeater.count; i++) {
			var item = repeater.itemAt(i)
			diskTotalspace += item.totalspace
			// console.log('totalspace', diskTotalspace, 'calc', item.usedspace, item.freespace, item.totalspace)
		}
		totalspace = diskTotalspace
	}

	onTotalspaceChanged: updatePartitionSizes()
	onWidthChanged: updatePartitionSizes()
	function updatePartitionSizes() {
		if (diskUsageBar.totalspace > 0) {
			var contentWidth = width - Math.max(0, (repeater.count - 1) * spacing)
			// console.log(diskUsageBar, 'updatePartitionSizes', 'contentWidth', contentWidth)
			for (var i = 0; i < repeater.count; i++) {
				var item = repeater.itemAt(i)

				var preferredWidth = diskUsageBar.contentWidth * (item.totalspace / diskUsageBar.totalspace)
				// console.log(item, item.partitionPath, preferredWidth, diskUsageBar.contentWidth, item.totalspace, diskUsageBar.totalspace)

				item.Layout.preferredWidth = preferredWidth
				// item.Layout.preferredWidth = Qt.binding(function(){
				// 	return diskUsageBar.width * (item.totalspace / diskUsageBar.totalspace)
				// })
			}
		}
	}


	// Timer {
	// 	running: true
	// 	// interval: 2000
	// 	repeat: true
	// 	interval: 1000
	// 	onTriggered: updatePartitionSizes()
	// }
}
