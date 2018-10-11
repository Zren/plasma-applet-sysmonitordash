SensorGraph {
	property string interfaceName
	sensors: [
		"network/interfaces/" + interfaceName + "/receiver/data",
		"network/interfaces/" + interfaceName + "/transmitter/data",
	]
	colors: [
		"#80b",
		"#b08",
	]
	label: i18n("Network")
	sublabel: interfaceName
	valueLabel: formatValuesLabel()
	
	function formatLabel(value, units) {
		return humanReadableBits(value)
	}
}
