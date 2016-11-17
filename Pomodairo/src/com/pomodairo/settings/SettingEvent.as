/**
 * Created by akalanitski on 16.11.2016.
 */
package com.pomodairo.settings {
import flash.events.Event;

public class SettingEvent extends Event {

	public static const CHANGED:String = "setting.changed";

	public function SettingEvent(type:String,
								 bubbles:Boolean = false,
								 cancelable:Boolean = false) {

		super(type, bubbles, cancelable);
	}
}
}
