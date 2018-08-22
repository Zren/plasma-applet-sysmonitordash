SensorGraph {
	property string partitionId
	sensors: [
		"disk/" + partitionId + "/Rate/rblk",
		"disk/" + partitionId + "/Rate/wblk",
	]
	colors: [
		"#094",
		"#8fc",
	]
	label: "Disk"
	sublabel: partitionId
	valueLabel: humanReadableBits(maxY)
	valueSublabel: i18n("%1 | %2", humanReadableBits(values[0]), humanReadableBits(values[1]))
}
