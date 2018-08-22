import QtQuick 2.1
import QtQuick.Layouts 1.3

ColumnLayout {
	id: diskMonitor
	spacing: units.smallSpacing

	property alias icon: ioGraph.icon
	property alias iconOverlays: ioGraph.iconOverlays
	property alias label: ioGraph.label
	property alias sublabel: ioGraph.sublabel
	property alias partitionId: ioGraph.partitionId

	property alias partitionPaths: usageBar.partitionPaths

	DiskIOGraph {
		id: ioGraph
		icon: "drive-harddisk"
	}
	DiskUsageBar {
		id: usageBar
	}
}
