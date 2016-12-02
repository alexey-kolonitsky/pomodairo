/**
 * Created by akalanitski on 02.12.2016.
 */
package com.pomodairo.components {
import flash.display.BitmapData;

import mx.core.UIComponent;

/**
 * Simple graphic to draw text glyph or icon.
 *
 * @author Alexey Kolonitsky <alexey.s.kolonitsky@gmail.com>
 */
public class Glyph extends UIComponent {

	public var _bitmapData:BitmapData;
	public var _bitmapDataChanged:Boolean = false;

	public function get bitmapData():BitmapData {
		return _bitmapData;
	}

	public function set bitmapData(value:BitmapData) {
		if (value == _bitmapData) {
			return;
		}
		_bitmapData = value;
		_bitmapDataChanged = true;
		invalidateSize();
		invalidateDisplayList();
	}


	override protected function measure():void {
		super.measure();
		if (_bitmapData) {
			measuredWidth = _bitmapData.width;
			measuredHeight = _bitmapData.height;
		}
	}


	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var color:uint = getStyle("color");

	}
}
}
