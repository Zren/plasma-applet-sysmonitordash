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
	valueSublabel: formatValuesLabel()
}
