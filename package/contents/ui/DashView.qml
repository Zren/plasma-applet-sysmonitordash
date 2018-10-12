import QtQuick 2.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.1

import org.kde.plasma.private.kicker 0.1 as Kicker

Kicker.DashboardWindow {
	id: window

	backgroundColor: Qt.rgba(0, 0, 0, 0.737)

	onKeyEscapePressed: {
		window.toggle();
	}
	
	mainItem: MouseArea {
		anchors.fill: parent

		acceptedButtons: Qt.LeftButton | Qt.RightButton

		onClicked: {
			if (mouse.button == Qt.LeftButton) {
				window.toggle();
			}
		}

		RowLayout {
			anchors.fill: parent
			spacing: units.largeSpacing

			ColumnLayout {
				Layout.preferredWidth: parent.width / 3
				spacing: units.largeSpacing * 3

				Repeater {
					model: config.diskModel
					DiskMonitor {
						label: modelData.label
						sublabel: modelData.sublabel
						partitionId: modelData.partitionId
						partitionPaths: modelData.partitionPaths
					}
				}
				
				Item { Layout.fillHeight: true }
			}


			ColumnLayout {
				Layout.preferredWidth: parent.width / 3
				spacing: units.largeSpacing

				SensorGraph {
					icon: "cpu"
					sensors: {
						var l = []
						for (var i = 0; i < sensorData.cpuCount; i++) {
							l.push("cpu/cpu" + i + "/TotalLoad")
						}
						return l
					}
					defaultMax: sensorData.cpuCount * 100
					stacked: true
					colors: [
						"#98AF93",
						"#708FA3",
						"#486F88",
						"#29526D",
						"#123852",
						"#032236",
					]
					valueUnits: '%'
					label: i18n("CPU")
					sublabel: plasmoid.configuration.cpuSublabel || deviceData.processorProduct
					valueFont.family: "Hack"
					valueLabel: formatLabel(sensorData.cpuTotalLoad, '%')
					valueSublabel: {
						var s = ""
						for (var i = 0; i < values.length; i++) {
							if (i > 0) {
								s += " | "
							}
							s += formatLabel(values[i], valueUnits)
						}
						return s
					}
					// valueSublabel: formatValuesLabel()
					maxYVisible: false

					function fixedWidth(x, n) {
						var s = "" + x
						while (s.length < n) {
							s = " " + s
						}
						return s
					}

					function formatLabel(value, units) {
						return fixedWidth(Math.round(value), 3) + " " + units
					}
				}

				SensorGraph {
					icon: "media-flash"
					sensors: [
						"mem/physical/cached",
						"mem/physical/buf",
						"mem/physical/application",
					]
					defaultMax: sensorData.memTotal
					stacked: true
					colors: [
						"#1122aa22",
						"#11aaeeaa",
						"#336699",
					]
					label: i18n("RAM")
					sublabel: plasmoid.configuration.ramSublabel || humanReadableBits(sensorData.memTotal)
					valueLabel: i18n("Unused: %1%\nCached: %2%\nBuffered: %3%\nApps: %4%",
						Math.round(sensorData.memFreePercent),
						Math.round(sensorData.memCachedPercent),
						Math.round(sensorData.memBuffersPercent),
						Math.round(sensorData.memAppsPercent))
					maxYVisible: false

					function formatLabel(value, units) {
						return humanReadableBits(value)
					}
				}

				SensorGraph {
					icon: "media-flash"
					sensors: [
						"mem/swap/used",
					]
					defaultMax: sensorData.swapTotal
					stacked: true
					colors: [
						"#1122aa22",
					]
					label: i18n("Swap")
					sublabel: plasmoid.configuration.swapSublabel || humanReadableBits(sensorData.swapTotal)
					valueLabel: i18n("Free: %1%\nUsed: %2%",
						Math.round(sensorData.swapFreePercent),
						Math.round(sensorData.swapUsedPercent))
					maxYVisible: false

					function formatLabel(value, units) {
						return humanReadableBits(value)
					}
				}

				Repeater {
					model: config.networkModel

					NetworkIOGraph {
						label: modelData.label
						icon: modelData.icon
						interfaceName: modelData.interfaceName
					}
				}
				
				
				Item { Layout.fillHeight: true }
			}

			ColumnLayout {
				Layout.preferredWidth: parent.width / 3
				spacing: units.largeSpacing

				Repeater {
					model: config.sensorModel

					SensorGraph {
						icon: modelData.icon || ""
						iconOverlays: modelData.iconOverlays || []
						sensors: modelData.sensors || []
						colors: modelData.colors || []
						defaultMax: modelData.defaultMax || 0
						label: modelData.label || ""
						sublabel: modelData.sublabel || ""
						valueUnits: modelData.units || undefined
					}
				}
				
				Item { Layout.fillHeight: true }
			}
		}
		
	}

	function humanReadableBits(kilobits) {
		if (kilobits > 1000000000) {
			return i18n("%1 TB", Math.round(kilobits/1000000000))
		} else if (kilobits > 1000000) {
			return i18n("%1 GB", Math.round(kilobits/1000000))
		} else if (kilobits > 1000) {
			return i18n("%1 MB", Math.round(kilobits/1000))
		} else {
			return i18n("%1 KB", Math.round(kilobits))
		}
	}
}
