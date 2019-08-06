import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."
import "../lib"

ConfigPage {
	ConfigSection {
		label: i18n("Dashboard Sensors")

		ConfigSpinBox {
			before: i18n("Update Every:")
			configKey: 'dashUpdateInterval'
			minimumValue: 50
			stepSize: 50
			suffix: i18n("ms")
		}
		ConfigSpinBox {
			before: i18n("Visible Duration:")
			configKey: 'dashVisibleDuration'
			minimumValue: 5
			stepSize: 5
			suffix: i18n("sec")
		}
	}
	ConfigSection {
		label: i18n("Panel Icon")

		ConfigSpinBox {
			id: iconUpdateInterval
			before: i18n("Update Every:")
			configKey: 'iconUpdateInterval'
			minimumValue: 50
			stepSize: 50
			suffix: i18n("ms")
		}
		ConfigSpinBox {
			before: i18n("Visible Duration:")
			enabled: false
			value: iconUpdateInterval.configValue * 5 / 1000
			suffix: i18n("sec")
		}
	}
}
