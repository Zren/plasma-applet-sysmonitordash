SensorGraph {
	property string partitionId
	sensors: [
		"disk/" + partitionId + "/Rate/rblk",
		"disk/" + partitionId + "/Rate/wblk",
	]
	legendLabels: [
		i18n("Read"),
		i18n("Write"),
	]
	colors: [
		"#094",
		"#8fc",
	]
	label: "Disk"
	sublabel: partitionId

	function formatLabel(value, units) {
		return humanReadableBytes(value)
	}
}
