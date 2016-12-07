/**
 * Created by akalanitski on 07.12.2016.
 */
package com.pomodairo.components {
import flash.events.MouseEvent;

import spark.components.supportClasses.ItemRenderer;

public class PomodairoBaseRenderer extends ItemRenderer {
	import com.pomodairo.EmbedStyle;
	import com.pomodairo.Pomodoro;

	public static const POMODORO_WIDTH:int = 2;
	public static const POMODORO_GAP:int = 2;
	public static const POMODORO_HEIGHT:int = 20;

	private var _drawBackground:Boolean = false;
	private var _backgroundColor:uint;

	protected var _estimated:int = 0;
	protected var _actual:int = 0;
	protected var _unplanned:int = 0;
	protected var _strikethrough:Boolean = false;

	//--------------------------------------------------------------------------
	// ItemRenderer
	//--------------------------------------------------------------------------

	override public function set selected(value:Boolean):void {
		super.selected = value;
		if (selected) {
			_drawBackground = true;
			_backgroundColor = EmbedStyle.LIST_SELECT_BACKGROUND;
		} else {
			_drawBackground = false;
		}
		invalidateDisplayList();
	}


	//--------------------------------------------------------------------------
	// UIComponent
	//--------------------------------------------------------------------------

	override public function initialize():void {
		addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		super.initialize();
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {

		setStyle('color', EmbedStyle.COMMON_TEXT_COLOR);
		setStyle('fontStyle', 'normal');
		setStyle('fontWeight', 'normal');

		super.updateDisplayList(unscaledWidth, unscaledHeight);

		graphics.clear();
		drawBackground();
		drawPomodoros();

		if (_strikethrough) {
			graphics.lineStyle(1, this.getStyle("color"));
			graphics.moveTo(28, unscaledHeight / 2);
			graphics.lineTo(unscaledWidth - 28, unscaledHeight / 2);
		} else {
			if (_estimated == 0) {
				setStyle('color', 0x777777);
			}
			if (_estimated < data.pomodoros) {
				setStyle('color', 0xCC0000);
			}
			if (_actual > 0) {
				setStyle('fontWeight', 'bold');
			}
		}
	}


	//--------------------------------------------------------------------------
	// Private
	//--------------------------------------------------------------------------

	private function drawBackground():void {
		if (_drawBackground) {
			this.graphics.lineStyle();
			this.graphics.beginFill(_backgroundColor);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
		}
	}

	private function drawPomodoros():void {

		var i:int;
		var xPosition:int;
		var yPosition:int = 4;

		// draw planed pomodoros
		this.graphics.lineStyle();
		this.graphics.beginFill(EmbedStyle.POMODORO_ESTIMATED_COLOR);
		for (i = 0; i < _estimated; i++) {
			xPosition = unscaledWidth - (POMODORO_WIDTH + POMODORO_GAP) * (i + 1);
			this.graphics.drawRect(xPosition, yPosition, POMODORO_WIDTH, POMODORO_HEIGHT);
		}

		// draw done pomodoros
		this.graphics.lineStyle();
		var n:int = _actual + _unplanned;
		for (i = 0; i < n; i++) {
			xPosition = unscaledWidth - (POMODORO_WIDTH + POMODORO_GAP) * (i + 1);
			var doneColor:uint = i < _estimated && i < _actual ? EmbedStyle.POMODORO_DONE_COLOR : EmbedStyle.POMODORO_OVERFLOW_COLOR;
			var color:uint = i < _actual ? doneColor : EmbedStyle.POMODORO_UNPLANED_COLOR;
			this.graphics.beginFill(color);
			this.graphics.drawRect(xPosition, yPosition, POMODORO_WIDTH, POMODORO_HEIGHT);
		}
	}

	//--------------------------------------------------------------------------
	// Event Handlers
	//--------------------------------------------------------------------------

	private function mouseOverHandler(event:MouseEvent):void {
		_drawBackground = true;
		_backgroundColor = EmbedStyle.LIST_OVER_BACKGROUND;
		invalidateDisplayList();
	}

	private function mouseOutHandler(event:MouseEvent):void {
		if (selected) {
			_drawBackground = true;
			_backgroundColor = EmbedStyle.LIST_SELECT_BACKGROUND;
		} else {
			_drawBackground = false;
		}
		invalidateDisplayList();
	}

	private function mouseDownHandler(event:MouseEvent):void {
		_drawBackground = true;
		_backgroundColor = EmbedStyle.LIST_SELECT_BACKGROUND;
		invalidateDisplayList();
	}
}
}
