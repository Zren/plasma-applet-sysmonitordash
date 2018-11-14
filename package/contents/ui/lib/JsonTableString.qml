import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

TableViewColumn {
	id: tableViewColumn

	movable: false

	property string placeholderText: ""

	delegate: JsonTableTextField {
		placeholderText: tableViewColumn.placeholderText
	}
}
