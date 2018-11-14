import QtQuick 2.0

QtObject {
	function getPreset(sensorName) {
		var match = sensorName.match(/^lmsensors\/((.+)\/(fan\d+))$/)
		if (match) {
			var fanPreset = {
				icon: 'fan',
				colors: ["#888"],
				label: i18n("Fan"),
				sublabel: match[1],
				defaultMax: 2000,
			}
			return fanPreset
		}

		var match = sensorName.match(/^lmsensors\/((.+)\/(temp\d+))$/)
		if (match) {
			var tempPreset = {
				colors: ["#800"],
				label: i18n("Temp"),
				sublabel: match[1],
				defaultMax: 70,
			}
			var chipName = match[2]
			if (chipName.match(/^radeon-/) || chipName.match(/^amdgpu-/)) {
				tempPreset.icon = 'amd-logo'
				tempPreset.label = i18n("GPU")
			}
			
			return tempPreset
		}

		return {}
	}
}
