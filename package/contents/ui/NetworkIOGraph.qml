SensorGraph {
	property string interfaceName
	sensors: [
		"network/interfaces/" + interfaceName + "/receiver/data",
		"network/interfaces/" + interfaceName + "/transmitter/data",
	]
	legendLabels: [
		i18n("Download"),
		i18n("Upload"),
	]
	colors: [
		"#80b",
		"#b08",
	]
	label: i18n("Network")
	sublabel: interfaceName
	
	function formatLabel(value, units) {
		return humanReadableBytes(value)
	}
}
