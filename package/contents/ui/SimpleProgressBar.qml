import QtQuick 2.0

Rectangle {
	id: simpleProgressBar
	color: "#88E6E6E6"
	border.width: 1
	border.color: "#88D0D0D0"

	property real value: 0
	property real maxValue: 100
	readonly property real ratio: maxValue > 0 ? value / maxValue : 0

	Rectangle {
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: parent.width * ratio
		color: ratio < 0.95 ? "#26a0da" : "#da2626"
	}
}
