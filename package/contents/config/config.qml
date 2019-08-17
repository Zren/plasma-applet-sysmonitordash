import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
	ConfigCategory {
		name: i18n("Sensors")
		icon: "utilities-system-monitor"
		source: "config/ConfigSensors.qml"
	}
	ConfigCategory {
		name: i18n("Networks")
		icon: "network-wireless"
		source: "config/ConfigNetworks.qml"
	}
	ConfigCategory {
		name: i18n("Settings")
		icon: "configure"
		source: "config/ConfigSettings.qml"
	}
}
