import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import "lib"

Item {
	id: main

	DeviceData {
		id: deviceData
	}

	SensorData {
		id: sensorData
		interval: config.sensorInterval
	}

	QtObject {
		id: config
		property int sensorInterval: plasmoid.configuration.dashUpdateInterval
		property int visibleDuration: plasmoid.configuration.dashVisibleDuration * 1000
		property int iconSensorInterval: plasmoid.configuration.iconUpdateInterval
		// property int iconVisibleDuration: iconSensorInterval * 5

		property var diskModel: []
		property var networkModel: []
		property var sensorModel: []
	}

	SensorPresets {
		id: sensorPresets
	}

	function initJsonObjArr(configKey) {
		// `plasmoid.configuration` is a QQmlPropertyMap
		// https://github.com/KDE/plasma-framework/blob/master/src/scriptengines/qml/plasmoid/appletinterface.cpp#L161
		// https://github.com/KDE/kdeclarative/blob/master/src/kdeclarative/configpropertymap.h
		plasmoid.configuration.valueChanged.connect(function(key, value){
			if (key == configKey) {
				config[configKey] = JSON.parse(plasmoid.configuration[configKey])
			}
		})
		config[configKey] = JSON.parse(plasmoid.configuration[configKey])
	}


	Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

	ExecUtil {
		id: execUtil
	}

	ListBlockDevices {
		id: lsblk
	}

	NetworkListDetector {
		id: networkListDetector
		onNetworkModelChanged: {
			config.networkModel = networkModel
		}
	}

	function action_openTaskManager() {
		execUtil.exec("ksysguard")
	}

	Component.onCompleted: {
		plasmoid.setAction("openTaskManager", i18n("Start Task Manager"), "utilities-system-monitor");

		// initJsonObjArr('diskModel')
		// initJsonObjArr('networkModel')
		initJsonObjArr('sensorModel')

		// plasmoid.action("configure").trigger()
	}

	// NOTE: taken from redshift plasmoid (who took in from colorPicker)
	// This prevents the popup from actually opening, needs to be queued.
	Timer {
		id: delayedUnexpandTimer
		interval: 0
		onTriggered: {
			plasmoid.expanded = false
		}
	}
	function toggleDialog() {
		delayedUnexpandTimer.start()
		dashView.toggle()
	}
	Plasmoid.onActivated: main.toggleDialog()

	DashView {
		id: dashView
	}
	Plasmoid.compactRepresentation: MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton
		onClicked: {
			if (mouse.button == Qt.LeftButton) {
				plasmoid.activated()
			} else {
				main.toggleSensors()
			}
		}

		// PlasmaCore.IconItem {
		// 	anchors.fill: parent
		// 	source: "utilities-system-monitor"
		// }

		Rectangle {
			anchors.fill: parent
			radius: 2
			gradient: Gradient {
				GradientStop { position: 0.0; color: "#424649" }
				GradientStop { position: 1.0; color: "#2a2c2f" }
			}

			KQuickAddons.Plotter {
				id: compactPlotter
				anchors.fill: parent
				sampleSize: 5
				rangeMin: 0
				rangeMax: 100
				autoRange: false

				dataSets: [
					KQuickAddons.PlotData {
						color: "#77b76b"
					}
				]
				
				Component.onCompleted: {
					// addSample([5])
					// addSample([8])
					// addSample([4])
					// addSample([6])
					// addSample([4])
					addSample([0])
					addSample([0])
				}

				Timer {
					interval: config.iconSensorInterval
					running: sensorData.running
					repeat: true
					onTriggered: {
						compactPlotter.addSample([sensorData.cpuTotalLoad])
					}
				}
			}

			Item {
				id: pauseIcon
				visible: !sensorData.running

				anchors.centerIn: parent
				readonly property int minSize: Math.min(parent.width, parent.height)
				width: minSize
				height: minSize
				
				Rectangle {
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.margins: parent.width * 1/5
					width: parent.width * 1/5
					color: "#40FFFFFF"
					border.color: "#80000000"
					border.width: 1 * units.devicePixelRatio
				}

				Rectangle {
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.right: parent.right
					anchors.margins: parent.width * 1/5
					width: parent.width * 1/5
					color: "#40FFFFFF"
					border.color: "#80000000"
					border.width: 1 * units.devicePixelRatio
				}
			}
		}
	}

	function toggleSensors() {
		sensorData.running = !sensorData.running
	}
}
