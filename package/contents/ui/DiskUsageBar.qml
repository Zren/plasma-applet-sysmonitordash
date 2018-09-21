import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

Item {
	id: diskUsageBar
	Layout.fillWidth: true
	Layout.preferredHeight: 16 * units.devicePixelRatio

	property var partitionPaths: []
	property int minimumPartitionWidth: 30 * units.devicePixelRatio

	Row {
		id: row
		anchors.fill: parent

		spacing: 4 * units.devicePixelRatio

		Repeater {
			id: repeater
			model: partitionPaths

			PartitionUsageBar {
				partitionPath: modelData
				onTotalspaceChanged: diskUsageBar.updateDiskSize()

				height: parent.height
			}
		}
	}

	property double totalspace: 0
	function updateDiskSize() {
		// console.log('updateDiskSize', partitionPaths)
		var diskTotalspace = 0
		for (var i = 0; i < repeater.count; i++) {
			var item = repeater.itemAt(i)
			diskTotalspace += item.totalspace
			// console.log('\ttotalspace', diskTotalspace, 'calc', item.usedspace, item.freespace, item.totalspace)
		}
		totalspace = diskTotalspace
		// updatePartitionSizes()
	}


	onTotalspaceChanged: updatePartitionSizes()
	onWidthChanged: updatePartitionSizes()
	function updatePartitionSizes() {
		if (diskUsageBar.totalspace > 0) {
			var contentWidth = width - Math.max(0, (repeater.count - 1) * spacing)
			// var extraWidth = Math.max(0, contentWidth - Math.max(0, (repeater.count - 1) * minimumPartitionWidth))
			var extraWidth = contentWidth - Math.max(0, (repeater.count) * minimumPartitionWidth)
			// console.log('updatePartitionSizes')
			// console.log('\t', 'contentWidth', contentWidth)
			// console.log('\t', 'extraWidth', extraWidth)
			for (var i = 0; i < repeater.count; i++) {
				var item = repeater.itemAt(i)

				var scaledExtraWidth = extraWidth * (item.totalspace / diskUsageBar.totalspace)
				var preferredWidth = minimumPartitionWidth + scaledExtraWidth
				// console.log('\t', extraWidth, scaledExtraWidth, preferredWidth, minimumPartitionWidth)

				item.width = preferredWidth
				// item.implicitWidth = preferredWidth
				// item.Layout.preferredWidth = preferredWidth
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
