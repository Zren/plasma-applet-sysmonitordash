import QtQuick 2.0
import QtQuick.Controls 2.0
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
			text: i18n("Used: %1\nFree: %2", humanReadableBits(usedspace), humanReadableBits(freespace))
		}
	}

	Layout.fillWidth: true
	Layout.preferredHeight: Screen.height / 100
	property int labelPadding: 4 * units.devicePixelRatio

	implicitWidth: label.paintedWidth
	Layout.minimumWidth: {
		if (showLabel) {
			return label.paintedWidth // Math.max(Screen.height / 100, label.paintedWidth)
		} else {
			return Screen.height / 100
		}
	}
	// Layout.maximumWidth: Number.POSITIVE_INFINITY

	Layout.minimumHeight: {
		if (showLabel) {
			return label.paintedHeight // Math.max(Screen.height / 100, label.paintedHeight)
		} else {
			return Screen.height / 100
		}
	}

	property string partitionPath
	readonly property double usedspace: sensorData.getData('partitions' + partitionPath + '/usedspace')
	readonly property double freespace: sensorData.getData('partitions' + partitionPath + '/freespace')
	readonly property double filllevel: sensorData.getData('partitions' + partitionPath + '/filllevel')
	readonly property double totalspace: usedspace + freespace
	readonly property bool isMounted: totalspace > 0

	property alias label: label.text
	property alias showLabel: label.visible

	// onUsedspaceChanged: console.log(partitionPath, 'usedspace', usedspace)
	// onFreespaceChanged: console.log(partitionPath, 'freespace', freespace)
	// onFilllevelChanged: console.log(partitionPath, 'filllevel', filllevel)

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
