import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: sensorData

	function getData(key) {
		if (typeof dataSource.data[key] === 'undefined') return 0;
		if (typeof dataSource.data[key].value === 'undefined') return 0;
		return dataSource.data[key].value;
	}
	function getUnits(key) {
		if (typeof dataSource.data[key] === 'undefined') return '';
		if (typeof dataSource.data[key].units === 'undefined') return '';
		return dataSource.data[key].units;
	}

	readonly property real cpuTotalLoad: getData(dataSource.totalLoad)
	readonly property real memApps: getData(dataSource.memApplication)
	readonly property real memBuffers: getData(dataSource.memBuffers)
	readonly property real memCached: getData(dataSource.memCached)
	readonly property real memUsed: getData(dataSource.memUsed)
	readonly property real memFree: getData(dataSource.memFree)
	readonly property real memTotal: memUsed + memFree
	readonly property real swapUsed: getData(dataSource.swapUsed)
	readonly property real swapFree: getData(dataSource.swapFree)
	readonly property real swapTotal: swapUsed + swapFree
	readonly property real cpuTotalLoadRatio: cpuTotalLoad / dataSource.maxCpuLoad
	readonly property real cpuTotalLoadPercent: cpuTotalLoadRatio * 100

	// readonly property real memAppsRatio: memTotal ? memApps / memTotal : 0
	// readonly property real memAppsPercent: memAppsRatio * 100
	// readonly property real memBuffersRatio: memTotal ? memBuffers / memTotal : 0
	// readonly property real memBuffersPercent: memBuffersRatio * 100
	// readonly property real memCachedRatio: memTotal ? memCached / memTotal : 0
	// readonly property real memCachedPercent: memCachedRatio * 100
	// readonly property real memUsedRatio: memTotal ? memUsed / memTotal : 0
	// readonly property real memUsedPercent: memUsedRatio * 100
	// readonly property real memFreeRatio: memTotal ? memFree / memTotal : 0
	// readonly property real memFreePercent: memFreeRatio * 100
	function memPercentage(value) {
		var ratio = memTotal ? value / memTotal : 0
		return ratio * 100
	}
	
	readonly property real swapUsedRatio: swapTotal ? swapUsed / swapTotal : 0
	readonly property real swapUsedPercent: swapUsedRatio * 100
	readonly property real swapFreeRatio: swapTotal ? swapFree / swapTotal : 0
	readonly property real swapFreePercent: swapFreeRatio * 100

	readonly property int cpuCount: dataSource.maxCpuIndex + 1

	readonly property var partitionsList: getData(dataSource.partitionsList)
	// onPartitionsListChanged: console.log('partitionsList', partitionsList)

	readonly property real uploadSpeed: getData(dataSource.uploadSource)
	readonly property real downloadSpeed: getData(dataSource.downloadSource)

	property var networkSensorList: []

	// /usr/share/plasma/plasmoids/org.kde.plasma.systemloadviewer/contents/ui/SystemLoadViewer.qml
	property alias dataSource: dataSource
	property alias interval: dataSource.interval

	Timer {
		id: timer
		repeat: true
		running: true
		interval: dataSource.interval
		onTriggered: sensorData.dataTick()
	}
	signal dataTick()

	PlasmaCore.DataSource {
		id: dataSource
		engine: "systemmonitor"

		readonly property double maxCpuLoad: 100.0


		property string cpuSystem: "cpu/system/"
		property string niceLoad: cpuSystem + "nice"
		property string userLoad: cpuSystem + "user"
		property string sysLoad: cpuSystem + "sys"
		property string ioWait: cpuSystem + "wait"
		property string averageClock: cpuSystem + "AverageClock"
		property string totalLoad: cpuSystem + "TotalLoad"
		property string memPhysical: "mem/physical/"
		property string memFree: memPhysical + "free"
		property string memApplication: memPhysical + "application"
		property string memBuffers: memPhysical + "buf"
		property string memCached: memPhysical + "cached"
		property string memUsed: memPhysical + "used"
		property string swap: "mem/swap/"
		property string swapUsed: swap + "used"
		property string swapFree: swap + "free"

		property string partitionsList: "partitions/list"

		property string deviceName: 'enp3s0' //'wlp5s6' //appletProxyModel[0].DeviceName
		property string downloadSource: "network/interfaces/" + deviceName + "/receiver/data"
		property string uploadSource: "network/interfaces/" + deviceName + "/transmitter/data"

		property var totalCpuLoadProportions: [.0, .0, .0, .0]
		property int maxCpuIndex: 0
		property var memoryUsageProportions: [.0, .0, .0]
		property double swapUsageProportion: .0

		connectedSources: [niceLoad, userLoad, sysLoad,
			ioWait, memFree, memApplication, memBuffers,
			memCached, memUsed, swapUsed, swapFree,
			averageClock, totalLoad,
			partitionsList,
			downloadSource, uploadSource]

		onSourceAdded: {
			// console.log('onSourceAdded', source)
			var match = source.match(/^cpu\/cpu(\w+)\//)
			if (match) {
				connectSource(source)
				if (maxCpuIndex < match[1]) {
					maxCpuIndex = match[1]
				}
			}

			match = source.match(/^network\/interfaces\/(\w+)\//)
			if (match) {
				var networkName = match[1]
				if (sensorData.networkSensorList.indexOf(networkName) === -1) {
					// Add if not seen before
					sensorData.networkSensorList.push(networkName)
					sensorData.networkSensorListChanged()
				}
			}
		}
		onSourceRemoved: {
			// console.log('onSourceRemoved', source)
		}

		onNewData: {
			if (typeof data.value === 'undefined') {
				return; // skip
			}

			// console.log(sourceName, data.value)

			if (sourceName == sysLoad) {
				totalCpuLoadProportions[0] = fitCpuLoad(data.value)
			}
			else if (sourceName == userLoad) {
				totalCpuLoadProportions[1] = fitCpuLoad(data.value)
			}
			else if (sourceName == niceLoad) {
				totalCpuLoadProportions[2] = fitCpuLoad(data.value)
			}
			else if (sourceName == ioWait) {
				totalCpuLoadProportions[3] = fitCpuLoad(data.value)
				totalCpuLoadProportionsChanged()
			}
			else if (sourceName == memApplication) {
				memoryUsageProportions[0] = fitMemoryUsage(data.value)
			}
			else if (sourceName == memBuffers) {
				memoryUsageProportions[1] = fitMemoryUsage(data.value)
			}
			else if (sourceName == memCached) {
				memoryUsageProportions[2] = fitMemoryUsage(data.value)
				memoryUsageProportionsChanged()
			}
			else if (sourceName == swapUsed) {
				swapUsageProportion = fitSwapUsage(data.value)
				swapUsageProportionChanged()
			}
		}
		interval: 1000

		function fitCpuLoad(load) {
			var x = load / maxCpuLoad;
			if (isNaN(x)) {return 0;}
			return Math.min(x, 1); // Ensure that we do not get values that might cause problems
		}

		function fitMemoryUsage(usage) {
			var x = (usage / (parseFloat(dataSource.data[dataSource.memFree].value) +
							 parseFloat(dataSource.data[dataSource.memUsed].value)))
			if (isNaN(x)) {return 0;}
			return Math.min(x, 1);
		}

		function fitSwapUsage(usage) {
			var x = (usage / (parseFloat(usage) + parseFloat(dataSource.data[dataSource.swapFree].value)))

			if (isNaN(x)) {return 0;}
			return Math.min(x, 1);
		}
	}
}
