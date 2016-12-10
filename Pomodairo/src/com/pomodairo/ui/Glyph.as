/**
 * Created by akalanitski on 02.12.2016.
 */
package com.pomodairo.ui {
import com.pomodairo.EmbedStyle;

import flash.display.BitmapData;
import flash.geom.ColorTransform;

import mx.core.UIComponent;

/**
 * Simple graphic to draw text glyph or icon.
 *
 * @author Alexey Kolonitsky <alexey.s.kolonitsky@gmail.com>
 */
public class Glyph extends UIComponent {


	public function Glyph() {
		super();
		var color:uint = EmbedStyle.COMMON_TEXT_COLOR;
		var mul:Number = 1;
		var ctMul:Number=(1-mul);
		var ctRedOff:Number=Math.round(mul * extractRed(color));
		var ctGreenOff:Number=Math.round(mul * extractGreen(color));
		var ctBlueOff:Number=Math.round(mul * extractBlue(color));
		var ct:ColorTransform  =new ColorTransform(ctMul,ctMul,ctMul,1,ctRedOff,ctGreenOff,ctBlueOff,0);
		this.transform.colorTransform=ct;
	}

	public function extractRed(c:uint):uint {
		return (( c >> 16 ) & 0xFF);
	}

	public function extractGreen(c:uint):uint {
		return ( (c >> 8) & 0xFF );
	}

	public function extractBlue(c:uint):uint {
		return ( c & 0xFF );
	}

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

		if (_bitmapData) {
			graphics.beginBitmapFill(_bitmapData);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
		}
	}
}
}
