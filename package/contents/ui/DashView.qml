import QtQuick 2.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.1

import org.kde.kcoreaddons 1.0 as KCoreAddons
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
					label: i18n("CPU")
					sublabel: plasmoid.configuration.cpuSublabel || deviceData.processorProduct
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
					legendLabels: [
						i18n("Cached"),
						i18n("Buffered"),
						i18n("Apps"),
					]
					legendItemsBefore: [
						formatItem('transparent', i18n("Free"), sensorData.memFree, ''),
					]
					defaultMax: sensorData.memTotal
					stacked: true
					colors: [
						"#1122aa22",
						"#11aaeeaa",
						"#336699",
					]
					label: i18n("RAM")
					sublabel: plasmoid.configuration.ramSublabel || humanReadableBytes(sensorData.memTotal)
					maxYVisible: false

					function formatLabel(value, units) {
						return humanReadableBytes(value) + " (" + Math.round(sensorData.memPercentage(value)) + "%)"
					}
				}

				SensorGraph {
					icon: "media-flash"
					sensors: [
						"mem/swap/used",
					]
					legendLabels: [
						i18n("Used"),
					]
					legendItemsBefore: [
						formatItem('transparent', i18n("Free"), sensorData.swapFree, ''),
					]
					defaultMax: sensorData.swapTotal
					stacked: true
					colors: [
						"#1122aa22",
					]
					label: i18n("Swap")
					sublabel: plasmoid.configuration.swapSublabel || humanReadableBytes(sensorData.swapTotal)
					maxYVisible: false

					function formatLabel(value, units) {
						return humanReadableBytes(value)
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
						icon: getSensorData('icon', "")
						iconOverlays: getSensorData('iconOverlays', [])
						sensors: modelData.sensors || []
						colors: getSensorData('colors', [])
						defaultMax: getSensorData('defaultMax', 0)
						label: getSensorData('label', "")
						sublabel: getSensorData('sublabel', "")
						valueUnits: modelData.units || sensorUnits

						function getSensorData(key, defaultValue) {
							if (typeof modelData === "undefined" || !modelData[key]) {
								if (typeof sensorPreset === "undefined" || typeof sensorPreset[key] === "undefined") {
									return defaultValue
								} else {
									return sensorPreset[key]
								}
							} else {
								return modelData[key]
							}
						}
					}
				}
				
				Item { Layout.fillHeight: true }
			}
		}
		
	}

	function humanReadableBytes(kibibytes) {
		// https://github.com/KDE/kcoreaddons/blob/master/src/lib/util/kformat.h
		return KCoreAddons.Format.formatByteSize(kibibytes * 1024)
	}

	// function humanReadableBytes(kibibytes) {
	// 	var kilobytes = kibibytes / 1024 * 1000
	// 	if (kilobytes > 1000000000) {
	// 		return i18n("%1 TB", Math.round(kilobytes/1000000000))
	// 	} else if (kilobytes > 1000000) {
	// 		return i18n("%1 GB", Math.round(kilobytes/1000000))
	// 	} else if (kilobytes > 1000) {
	// 		return i18n("%1 MB", Math.round(kilobytes/1000))
	// 	} else {
	// 		return i18n("%1 KB", Math.round(kilobytes))
	// 	}
	// }
}
