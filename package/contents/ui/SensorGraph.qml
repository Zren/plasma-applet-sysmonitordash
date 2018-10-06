import QtQuick 2.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.1
import QtQuick.Controls 2.0 // ToolTip

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
// import org.kde.kcoreaddons 1.0 as KCoreAddons

import "lib"

Item {
	id: sensorGraph
	property alias icon: plotter.icon
	property alias iconOverlays: plotter.iconOverlays
	property alias label: plotter.label
	property alias sublabel: plotter.sublabel
	property alias valueLabel: plotter.valueLabel
	property alias valueSublabel: plotter.valueSublabel
	property alias valueFont: plotter.valueFont
	property alias sensors: plotter.sensors
	property alias values: plotter.values
	property alias maxValue: plotter.maxValue
	property alias maxY: plotter.maxY
	property alias colors: plotter.colors
	property alias stacked: plotter.stacked
	property alias defaultMax: plotter.defaultMax
	property alias units: plotter.units

	property int padding: 4
	

	Layout.fillWidth: true
	Layout.preferredHeight: Screen.height / 10

	Rectangle {
		anchors.fill: parent
		color: Qt.rgba(0, 0, 0, 0.2)
		border.width: 1
		border.color: Qt.rgba(0, 0, 0, 0.8)
	}

	KQuickAddons.Plotter {
		id: plotter
		anchors.fill: parent

		property string icon: ''
		property alias iconOverlays: iconItem.overlays
		property string label: ''
		property string sublabel: ''
		property string valueLabel: formatLabel(values[0], plotter.units)
		property string valueSublabel: ''
		property alias valueFont: valueLabel.font
		property var sensors: []
		property var values: []

		readonly property var maxValue: values.length > 0 ? Math.max.apply(null, values) : 0
		property var maxY: 0
		onMaxValueChanged: {
			var m = 0
			for (var j = 0; j < dataSets.length; j++) {
				var dataset = dataSets[j]
				var datasetMax = dataset.max
				if (datasetMax > m) {
					m = datasetMax
				}
			}
			maxY = m
		}
		
		property var colors: [theme.highlightColor]
		property var units: undefined
		sampleSize: Math.floor(config.visibleDuration / config.sensorInterval) + 1


		//FIXME: doesn't seem to properly fill otherwise
		// Layout.preferredHeight: parent.height
		horizontalGridLineCount: 0

		autoRange: defaultMax == 0
		rangeMin: 0
		property real defaultMax: 0
		// rangeMax: {
		// 	if (defaultMax > 0) {
		// 		// console.log(sensor, defaultMax, max, Math.max(defaultMax, max))
		// 		return Math.max(defaultMax, max)
		// 	} else {
		// 		// console.log(sensor, defaultMax, max)
		// 		return max
		// 	}
		// }
		rangeMax: defaultMax > 0 ? Math.max(defaultMax, max) : max

		function addZero() {
			var values = new Array(plotter.sensors.length)
			for (var i = 0; i < plotter.sensors.length; i++) {
				values[i] = 0
			}
			plotter.addSample(values)
		}

		Component.onCompleted: {
			addZero()
			addZero()
			sensorsChanged()
		}

		Component {
			id: plotDataComponent
			KQuickAddons.PlotData {}
		}
		onSensorsChanged: {
			// console.log(sensor, sensorData.dataSource.connectedSources)
			var list = []
			for (var i = 0; i < sensors.length; i++) {
				if (!sensors[i]) {
					return
				}
				if (sensorData.dataSource.connectedSources.indexOf(sensors[i]) == -1) {
					sensorData.dataSource.connectSource(sensors[i])
				}

				var item = plotDataComponent.createObject(plotter, {
					color: plotter.colors[i % plotter.colors.length],
					sampleSize: plotter.sampleSize,
				})
				list.push(item)
			}
			dataSets = list

			// Trick Plotter into calling PlotData::setSampleSize()
			var size = plotter.sampleSize
			plotter.sampleSize = plotter.sampleSize + 1
			plotter.sampleSize = size
		}

		dataSets: []


		AppletIcon {
			id: iconItem
			visible: plotter.icon
			source: plotter.icon
			property int size: plotter.sublabel ? labelItem.height * 2 : labelItem.height
			width: visible ? size : 0
			height: visible ? size : 0
			anchors {
				left: parent.left
				top: parent.top
				leftMargin: sensorGraph.padding
				topMargin: sensorGraph.padding
			}
		}

		TextLabel {
			id: labelItem
			anchors {
				left: iconItem.right
				top: parent.top
				topMargin: sensorGraph.padding
			}
			text: plotter.label || ''

			// Rectangle { border.color: "#0f0"; anchors.fill: parent; color: "transparent"; border.width: 1}
		}
		TextLabel {
			id: sublabelItem
			anchors {
				left: iconItem.right
				top: labelItem.bottom
				rightMargin: sensorGraph.padding
			}
			text: plotter.sublabel || ''
			opacity: 0.75

			// Rectangle { border.color: "#ff0"; anchors.fill: parent; color: "transparent"; border.width: 1}
		}

		TextLabel {
			id: valueLabel
			wrapMode: Text.WordWrap
			anchors {
				right: parent.right
				top: parent.top
				rightMargin: sensorGraph.padding
				topMargin: sensorGraph.padding
			}
			horizontalAlignment: Text.AlignRight
			text: plotter.valueLabel || ''
			
			// Rectangle { border.color: "#ff0"; anchors.fill: parent; color: "transparent"; border.width: 1}
		}

		TextLabel {
			id: valueSublabel
			font: valueLabel.font
			wrapMode: Text.WordWrap
			anchors {
				right: parent.right
				top: valueLabel.bottom
				rightMargin: sensorGraph.padding
			}
			horizontalAlignment: Text.AlignRight
			text: plotter.valueSublabel || ''
			
			// Rectangle { border.color: "#ff0"; anchors.fill: parent; color: "transparent"; border.width: 1}
		}

		Connections {
			target: sensorData
			onDataTick: {
				var values = new Array(plotter.sensors.length)
				for (var i = 0; i < plotter.sensors.length; i++) {
					values[i] = sensorData.getData(sensors[i])
				}
				// console.log('values', values)
				plotter.addSample(values)
				plotter.values = values
			}
		}

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			acceptedButtons: Qt.NoButton
			hoverEnabled: true

			Rectangle {
				id: hoverLine
				visible: mouseArea.containsMouse
				width: 1
				height: parent.height
				x: mouseArea.mouseX
				opacity: 0.65
				color: "#FFF"
			}

			ToolTip {
				id: tooltip
				visible: mouseArea.containsMouse
				text: ""

				property int cursorMargin: 3
				x: mouseArea.mouseX - implicitWidth / 2
				y: mouseArea.mouseY - implicitHeight - cursorMargin

				onVisibleChanged: {
					if (visible) {
						tooltip.updateText()
					}
				}

				Connections {
					target: plotter
					enabled: tooltip.visible
					onValuesChanged: {
						tooltip.updateText()
					}
				}

				function updateText() {
					text = calcText()
				}

				function stripAlpha(c) {
					return Qt.rgba(c.r, c.g, c.b, 1)
				}

				function calcText() {
					var xOffset = mouseArea.mouseX - mouseArea.x
					var xRatio = xOffset / mouseArea.width

					var str = ""
					for (var j = 0; j < plotter.dataSets.length; j++) {
						if (j > 0) {
							str += "<br>"
						}
						var dataset = plotter.dataSets[j]
						var valueIndex = Math.round(xRatio * (dataset.values.length-1))
						var hoveredValue = dataset.values[valueIndex]
						
						str += '<font color="' + stripAlpha(dataset.color) + '">■</font> '
						str += formatLabel(hoveredValue, plotter.units)
					}

					return str
				}
			}
		}

	}

	function formatLabel(value, units) {
		// if (units === 'KB') {
		// 	return KCoreAddons.Format.formatByteSize(value * 1024);
		// } else {
		// 	return i18nc("%1 is data value, %2 is unit datatype", "%1 %2", Math.round(value), units);
		// }
		if (units) {
			return i18nc("%1 is data value, %2 is unit datatype", "%1 %2", Math.round(value), units);
		} else {
			return Math.round(value)
		}
	}
}
