/**
 * Created by akalanitski on 05.12.2016.
 */
package com.pomodairo.components {
import flash.events.MouseEvent;

public class Button extends Glyph {
	public function Button() {
		this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	}

	private function mouseOverHandler(event:MouseEvent):void {
		
	}

	private function mouseOutHandler(event:MouseEvent):void {

	}
}
}
