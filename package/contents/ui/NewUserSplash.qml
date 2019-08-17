import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lib"

Item {
	id: newUserSplash
	visible: config.sensorModel.length == 0

	// We need to expose this to disable the dashboard close on click.
	property alias configureButton: configureButton

	property color textColor: "#eeeff0"

	Layout.fillWidth: true

	implicitWidth: layout.implicitWidth
	implicitHeight: layout.implicitHeight

	Rectangle {
		anchors.fill: parent
		color: Qt.rgba(0, 0, 0, 0.2)
		border.width: 1
		border.color: Qt.rgba(0, 0, 0, 0.8)
	}

	ColumnLayout {
		id: layout
		anchors.fill: parent

		TextLabel {
			Layout.fillWidth: true
			Layout.margins: units.largeSpacing
			Layout.bottomMargin: 0
			text: i18n("You can hide disks and networks in the config. You can also monitor temperature and fan speed sensors if you have lm-sensors installed.")
			color: newUserSplash.textColor
			font.pointSize: theme.defaultFont.pointSize * 1.2
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.Wrap
		}

		PlasmaComponents.Button {
			id: configureButton
			Layout.alignment: Qt.AlignHCenter
			Layout.margins: units.largeSpacing
			text: i18n("Configure Sensors")
			iconSource: "configure"
			onClicked: {
				window.close()
				plasmoid.action("configure").trigger()
			}
		}
	}
}
