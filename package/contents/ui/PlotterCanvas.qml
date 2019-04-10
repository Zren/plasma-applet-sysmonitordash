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

	property var dataSets: []

	onPaint: {
		// console.log('onPaint')
		if (!context) {
			getContext("2d")
		}
		context.clearRect(0, 0, width, height)
		var adjustedMax = autoRange ? max : rangeMax
		var adjustedMin = autoRange ? min : rangeMin
		for (var i = 0; i < dataSets.length; i++) {
			var dataSet = dataSets[i]
			// console.log('dataSet', i, 'length=', dataSet.values.length, 'sampleSize=', dataSet.sampleSize, 'max=', adjustedMax, 'min=', adjustedMin)
			context.fillStyle = dataSet.color
			context.strokeStyle = dataSet.color
			context.lineWidth = 1 * units.devicePixelRatio
			context.beginPath()
			var rangeY = adjustedMax - adjustedMin
			for (var j = 0; j < dataSet.values.length; j++) {
				var value = dataSet.values[j]
				var x = dataSet.sampleSize >= 2 ? j/(dataSet.sampleSize-1) : 0
				var y = (value - adjustedMin) / (rangeY > 0 ? rangeY : 1)
				x = x * width
				y = y * height
				// console.log('\t', j, value, '(', Math.floor(x), Math.floor(y), ')')
				y = height - y
				context.lineTo(x, y)
			}
			context.lineTo(width, height) // bottom right
			context.lineTo(0, height) // bottom left
			context.closePath()
			context.fill()
			context.stroke()
		}
	}

	function normalizeData() {
		var adjustedMax = Number.NEGATIVE_INFINITY
		var adjustedMin = Number.POSITIVE_INFINITY
		if (stacked) {
			for (var i = 0; i < dataSets.length; i++) {
				var dataSet = dataSets[i]
			}
		} else {
			for (var i = 0; i < dataSets.length; i++) {
				var dataSet = dataSets[i]
				dataSet.normalizedValues = dataSet.values
				if (dataSet.max > max) {
					adjustedMax = max = dataSet.max
				}
				if (dataSet.min < min) {
					adjustedMin = min = dataSet.min
				}
			}
		}
	}

	function plotXY(x, y) {

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
	}

	onSampleSizeChanged: {
		for (var i = 0; i < dataSets.length; i++) {
			dataSets[i].setSampleSize(sampleSize)
		}
	}
}
