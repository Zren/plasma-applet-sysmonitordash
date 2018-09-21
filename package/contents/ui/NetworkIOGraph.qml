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
	valueLabel: i18n("%1", humanReadableBits(maxY))
	valueSublabel: i18n("%1 | %2", humanReadableBits(values[0]), humanReadableBits(values[1]))
	
	function formatLabel(value, units) {
		return humanReadableBits(value)
	}
}
