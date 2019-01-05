import QtQuick 2.7
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
	property alias maxYLabel: plotter.maxYLabel
	property alias maxYVisible: maxYItem.visible
	property alias sensors: plotter.sensors
	property alias values: plotter.values
	property alias maxValue: plotter.maxValue
	property alias maxY: plotter.maxY
	property alias colors: plotter.colors
	property alias stacked: plotter.stacked
	property alias defaultMax: plotter.defaultMax

	readonly property var sensorPreset: sensorPresets.getPreset(sensors[0])
	readonly property string sensorUnits: sensorData.getUnits(sensors[0])

	property string valueUnits: sensorUnits
	property var legendLabels: []
	property var legendItemsBefore: []

	property int padding: 4 * units.devicePixelRatio
	property int legendRadius: 6 * units.devicePixelRatio
	
	property color textColor: "#eeeff0"

	Layout.fillWidth: true
	Layout.preferredHeight: 120 * units.devicePixelRatio

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
		property string valueSublabel: ''
		property string maxYLabel: formatLabel(maxY, plotter.units)
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
		property var units: sensorGraph.valueUnits
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

		Item {
			id: legendArea
			anchors {
				left: labelItem.width > sublabelItem.width ? labelItem.right : sublabelItem.right
				top: parent.top
				bottom: parent.bottom
				right: parent.right

				leftMargin: sensorGraph.padding
				topMargin: sensorGraph.padding
				bottomMargin: sensorGraph.padding
				rightMargin: sensorGraph.padding * 8
			}
			// Rectangle { border.color: "#ff0"; anchors.fill: parent; color: "transparent"; border.width: 1}

			Rectangle {
				id: legendBackground
				anchors.centerIn: legendGridLayout
				width: legendGridLayout.width + sensorGraph.legendRadius*2
				height: legendGridLayout.height + sensorGraph.legendRadius*2
				color: "#80000000"
				radius: sensorGraph.legendRadius
			}

			GridLayout {
				id: legendGridLayout
				rowSpacing: 0
				columnSpacing: units.largeSpacing
				columns: Math.ceil(itemCount / 4)
				readonly property int itemCount: legendRepeaterBefore.count + legendRepeater.count

				anchors {
					// top: parent.top
					// topMargin: sensorGraph.padding

					// horizontalCenter: maxYVisible ? parent.horizontalCenter : undefined
					// centerIn: parent
					verticalCenter: parent.verticalCenter
					right: parent.right
				}

				Repeater {
					id: legendRepeaterBefore
					model: legendItemsBefore
					TextLabel {
						text: modelData
						color: sensorGraph.textColor

						// Grow width based on contents, never shrink.
						Layout.preferredWidth: 0
						onImplicitWidthChanged: {
							if (Layout.preferredWidth < implicitWidth) {
								Layout.preferredWidth = implicitWidth
							}
						}
					}
				}

				Repeater {
					id: legendRepeater
					model: values.length
					TextLabel {
						text: {
							var label = (index < legendLabels.length) ? legendLabels[index] : ''
							return formatItem(colors[index % colors.length], label, values[index], valueUnits)
						}
						color: sensorGraph.textColor

						// Grow width based on contents, never shrink.
						Layout.preferredWidth: 0
						onImplicitWidthChanged: {
							if (Layout.preferredWidth < implicitWidth) {
								Layout.preferredWidth = implicitWidth
							}
						}
					}
				}
				
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
			color: sensorGraph.textColor

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
			color: sensorGraph.textColor
			opacity: 0.75

			// Rectangle { border.color: "#ff0"; anchors.fill: parent; color: "transparent"; border.width: 1}
		}

		TextLabel {
			id: maxYItem
			anchors {
				right: parent.right
				top: parent.top
				rightMargin: sensorGraph.padding
				topMargin: sensorGraph.padding
			}
			horizontalAlignment: Text.AlignRight
			text: plotter.maxYLabel || ''
			color: sensorGraph.textColor
			opacity: 0.75
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
				delay: 0

				// minX + maxX workaround the bug where the tooltip appears on the
				// other side of the graph when it would hit the edge of the screen.
				property int cursorMargin: 3
				property int centerCursorX: mouseArea.mouseX - implicitWidth / 2
				property int minX: 8 * units.devicePixelRatio
				property int maxX: mouseArea.width - implicitWidth - minX
				x: Math.max(minX, Math.min(centerCursorX, maxX))
				y: mouseArea.height + cursorMargin

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

				function calcText() {
					var xOffset = mouseArea.mouseX - mouseArea.x
					var xRatio = xOffset / mouseArea.width

					if (plotter.dataSets.length > 0) {
						var datasetLength = plotter.dataSets[0].values.length
						var valueIndex = Math.round(xRatio * (datasetLength-1))
						return formatLegend(valueIndex)
					} else {
						return ""
					}
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

	function formatValuesLabel() {
		var str = ''
		for (var i = 0; i < values.length; i++) {
			if (i > 0) {
				str += "<br>"
			}
			var label = (i < legendLabels.length) ? legendLabels[i] : ''
			str += formatItem(colors[i % colors.length], label, values[i], valueUnits)
		}
		return str
	}



	function stripAlpha(c) {
		if (c) {
			if (typeof(c) == "string") {
				c = Qt.tint(c, "transparent")
			}
			return Qt.rgba(c.r, c.g, c.b, 1)
		} else {
			return Qt.rgba(0, 0, 0, 1)
		}
	}

	function formatLegend(valueIndex) {
		var str = ""
		for (var j = 0; j < plotter.dataSets.length; j++) {
			if (j > 0) {
				str += "<br>"
			}
			var dataset = plotter.dataSets[j]
			var hoveredValue = dataset.values[valueIndex]
			var label = ''

			str += formatItem(dataset.color, label, hoveredValue, plotter.units)
		}

		return str
	}

	function formatItem(color, label, value, units) {
		var str = ""
		str += '<font color="' + stripAlpha(color) + '">■</font> '
		if (label) {
			str += "<b>" + label + ":</b> "
		}
		str += formatLabel(value, units)
		return str
	}
}
