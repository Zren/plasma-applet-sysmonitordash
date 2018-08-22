import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons


// import "../code/utils.js" as Utils

Item {
	id: main

	SensorData {
		id: sensorData
		interval: config.sensorInterval
	}

	QtObject {
		id: config
		property int visibleDuration: 60 * 1000
		property int sensorInterval: 250
		property int iconSensorInterval: 1000
	}


	Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

	PlasmaCore.DataSource {
		id: executeSource
		engine: "executable"
		connectedSources: []
		onNewData: {
			disconnectSource(sourceName)
		}
	}
	function exec(cmd) {
		executeSource.connectSource(cmd)
	}

	function action_openTaskManager() {
		exec("ksysguard");
	}

	Component.onCompleted: {
		plasmoid.setAction("openTaskManager", i18n("Start Task Manager"), "utilities-system-monitor");
	}

	DashView {
		id: dashView
	}
	Plasmoid.compactRepresentation: MouseArea {
		anchors.fill: parent
		onClicked: dashView.toggle()

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
					running: true
					repeat: true
					onTriggered: {
						compactPlotter.addSample([sensorData.cpuTotalLoad])
					}
				}
			}
		}
	}
}
