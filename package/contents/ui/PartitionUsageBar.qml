import QtQuick 2.0
import QtQuick.Controls 2.0 // ToolTip
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

SimpleProgressBar {
	id: partitionUsageBar

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		acceptedButtons: Qt.NoButton
		hoverEnabled: true
		ToolTip {
			id: control
			visible: mouseArea.containsMouse
			text: i18n("<b>%1</b><br>Size: %2<br>Used: %3<br>Free: %4", partitionPath, humanReadableBytes(totalspace), humanReadableBytes(usedspace), humanReadableBytes(freespace))
			delay: 0
		}
	}

	property int labelPadding: 4 * units.devicePixelRatio

	property string partitionPath
	readonly property double usedspace: sensorData.getData('partitions' + partitionPath + '/usedspace')
	readonly property double freespace: sensorData.getData('partitions' + partitionPath + '/freespace')
	readonly property double filllevel: sensorData.getData('partitions' + partitionPath + '/filllevel')
	property double totalspace: 0
	readonly property bool isMounted: totalspace > 0

	property alias label: label.text
	property alias showLabel: label.visible

	Timer {
		id: totalspaceDebounce
		interval: 200
		onTriggered: {
			partitionUsageBar.totalspace = partitionUsageBar.usedspace + partitionUsageBar.freespace
		}
	}

	onUsedspaceChanged: {
		// console.log(partitionPath, 'usedspace', usedspace)
		totalspaceDebounce.restart()
	}
	onFreespaceChanged: {
		// console.log(partitionPath, 'freespace', freespace)
		totalspaceDebounce.restart()
	}
	// onFilllevelChanged: console.log(partitionPath, 'filllevel', filllevel)
	// onTotalspaceChanged: console.log(partitionPath, 'totalspace', totalspace)

	// value: usedspace / (usedspace+freespace)
	// maxValue: 1
	value: filllevel
	maxValue: 100

	opacity: isMounted ? 1 : 0.3

	function connectSource(sensor) {
		// console.log('connectedSources', sensor, sensorData.dataSource.connectedSources.indexOf(sensor))
		if (sensorData.dataSource.connectedSources.indexOf(sensor) == -1) {
			sensorData.dataSource.connectSource(sensor)
		}
	}

	Text {
		id: label
		opacity: (partitionUsageBar.width >= (labelPadding + contentWidth + labelPadding)) ? 1 : 0
		text: partitionPath
		color: "#ffffff"
		font.pointSize: -1
		font.pixelSize: parent.height - labelPadding // Half padding top+bottom since font has extra spacing
		font.bold: true
		style: Text.Outline
		styleColor: "#00000088"
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		anchors.leftMargin: labelPadding
		anchors.rightMargin: labelPadding
	}

	Connections {
		target: sensorData.dataSource
		onSourceAdded: {
			var partitionRegExp = new RegExp("^partitions(/.*)/filllevel$")
			var match = source.match(partitionRegExp)
			if (match) {
				// console.log('partitionRegExp', match, match[1])
				if (match[1] == partitionPath) {
					partitionUsageBar.connectSource('partitions' + partitionPath + '/usedspace')
					partitionUsageBar.connectSource('partitions' + partitionPath + '/freespace')
					partitionUsageBar.connectSource('partitions' + partitionPath + '/filllevel')
				}
			}
		}
	}

	// Component.onCompleted: {
	// 	connectSource('partitions' + partitionPath + '/usedspace')
	// 	connectSource('partitions' + partitionPath + '/freespace')
	// 	connectSource('partitions' + partitionPath + '/filllevel')
	// }
}
