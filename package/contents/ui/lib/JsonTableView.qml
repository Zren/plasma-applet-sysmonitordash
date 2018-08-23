import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

TableView {
	id: tableView
	signal cellChanged(int row, int cell, string role)
}
