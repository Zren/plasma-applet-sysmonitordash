// Version 1

import QtQuick 2.1
import QtQuick.Controls 1.1

ScrollView {
	id: scrollView

	readonly property int contentWidth: contentItem ? contentItem.width : width
	readonly property int contentHeight: contentItem ? contentItem.height : 0 // Warning: Binding loop
	readonly property int viewportWidth: viewport ? viewport.width : width
	readonly property int viewportHeight: viewport ? viewport.height : height
	readonly property int scrollY: flickableItem ? flickableItem.contentY : 0
}
