import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons


// Based on KQuickAddons.Plotter
// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrolsaddons/plotter.h
// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrolsaddons/plotter.cpp
Canvas {
	id: plotter
	property real max: 0
	property real min: 0
	property int sampleSize: 5
	property bool stacked: false
	property bool autoRange: false
	property real rangeMax: 100
	property real rangeMin: 0
	property color gridColor: '#000'
	property int horizontalGridLineCount: 0
	property bool normalizeRequested: true

	property var dataSets: []

	onPaint: {
		if (!context) {
			getContext("2d")
		}

		if (normalizeRequested) {
			normalizeData()
			normalizeRequested = false
		}

		context.clearRect(0, 0, width, height)

		var adjustedMax = autoRange ? max : rangeMax
		var adjustedMin = autoRange ? min : rangeMin
		var rangeY = adjustedMax - adjustedMin

		var prevPath = [
			[0, height], // bottom left
			[width, height], // bottom right
		]
		// var dataSetPaths = new Array(dataSets.length)

		for (var i = dataSets.length-1; i >= 0; i--) {
			var dataSet = dataSets[i]
			// console.log('dataSet', i, 'length=', dataSet.values.length, 'sampleSize=', dataSet.sampleSize, 'max=', adjustedMax, 'min=', adjustedMin)

			//--- Generate curPath
			var curPath = new Array(dataSet.normalizedValues.length)
			// dataSetPaths[i] = curPath
			context.beginPath()
			// console.log('dataSet', i, 'normalizedValues.length', dataSet.normalizedValues.length)
			for (var j = 0; j < dataSet.normalizedValues.length; j++) {
				var value = dataSet.normalizedValues[j]
				var x = dataSet.sampleSize >= 2 ? j/(dataSet.sampleSize-1) : 0
				var y = (value - adjustedMin) / (rangeY > 0 ? rangeY : 1)
				x = x * width
				y = y * height
				// console.log('\t', j, value, '(', Math.floor(x), Math.floor(y), ')')
				y = height - y
				curPath[j] = [x, y]

				// Navigate curPath
				context.lineTo(x, y)
			}
			// dataSetPaths[i] = curPath

			// Reverse navigate prevPath
			for (var j = prevPath.length-1; j >= 0; j--) {
				var p = prevPath[j]
				context.lineTo(p[0], p[1])
			}

			// Close and fill
			context.closePath()
			// context.fillStyle = Qt.rgba(dataSet.color.r, dataSet.color.g, dataSet.color.b, 0.65)
			context.fillStyle = dataSet.color
			// console.log('dataSet', i, dataSet.color, '=>', context.fillStyle)
			context.fill()

			prevPath = curPath
		}

		//--- Stroke lines
		// context.lineWidth = Math.floor(1 * units.devicePixelRatio)
		// for (var i = 0; i < dataSets.length; i++) {
		// 	var dataSet = dataSets[i]
		// 	var curPath = dataSetPaths[i]
		// 	context.beginPath()
		// 	for (var j = 0; j < curPath.length; j++) {
		// 		var p = curPath[j]
		// 		context.lineTo(p[0], p[1])
		// 	}
		// 	context.strokeStyle = dataSet.color
		// 	console.log('dataSet.stroke', i, dataSet.color)
		// 	context.stroke()
		// }
	}

	function normalizeData() {
		var adjustedMax = Number.NEGATIVE_INFINITY
		var adjustedMin = Number.POSITIVE_INFINITY
		if (stacked) {
			var prevDataSet = null
			for (var i = dataSets.length-1; i >= 0; i--) {
				var dataSet = dataSets[i]
				if (prevDataSet) {
					dataSet.normalizedValues = new Array(dataSet.values.length)
					for (var j = 0; j < dataSet.values.length; j++) {
						var normalizedValue = dataSet.values[j] + prevDataSet.normalizedValues[j]
						// if (normalizedValue !== 0) {
						// 	console.log('dataSets[', i, '].normalizedValues[', j, '].normalizedValue', normalizedValue, 'label', sensorGraph.label)
						// }
						dataSet.normalizedValues[j] = normalizedValue
						if (normalizedValue > adjustedMax) {
							adjustedMax = normalizedValue
						}
						if (normalizedValue < adjustedMin) {
							adjustedMin = normalizedValue
						}
					}
				} else {
					dataSet.normalizedValues = dataSet.values.slice()
					if (dataSet.max > adjustedMax) {
						adjustedMax = dataSet.max
					}
					if (dataSet.min > adjustedMin) {
						adjustedMin = dataSet.min
					}
				}
				prevDataSet = dataSet

				if (dataSet.max > max) {
					max = dataSet.max
				}
				if (dataSet.min > min) {
					min = dataSet.min
				}
			}
		} else {
			for (var i = 0; i < dataSets.length; i++) {
				var dataSet = dataSets[i]
				dataSet.normalizedValues = dataSet.values.slice()
				if (dataSet.max > max) {
					adjustedMax = max = dataSet.max
				}
				if (dataSet.min < min) {
					adjustedMin = min = dataSet.min
				}
			}
		}
	}

	function addSample(values) {
		for (var i = 0; i < dataSets.length; i++) {
			dataSets[i].addSample(values[i])
		}
		var maxValues = new Array(dataSets.length)
		var minValues = new Array(dataSets.length)
		for (var i = 0; i < dataSets.length; i++) {
			maxValues[i] = dataSets[i].max
			minValues[i] = dataSets[i].min
		}
		max = Math.max.apply(null, maxValues)
		min = Math.min.apply(null, minValues)
		normalizeRequested = true
	}

	function updateSampleSize() {
		for (var i = 0; i < dataSets.length; i++) {
			dataSets[i].setSampleSize(sampleSize)
		}
		// normalizeRequested = true
	}
	onSampleSizeChanged: {
		updateSampleSize()
	}

	onDataSetsChanged: {
		updateSampleSize()
	}
}
