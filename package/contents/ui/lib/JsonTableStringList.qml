import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

TableViewColumn {
	id: tableViewColumn

	movable: false

	delegate: JsonTableTextField {
		function getter() {
			return (styleData.value || '').join(',')
		}

		function setterValue() {
			return text.split(',')
		}
	}
}
