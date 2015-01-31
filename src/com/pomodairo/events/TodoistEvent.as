package com.pomodairo.events
{
	import flash.events.Event;

	public class TodoistEvent extends Event
	{
		public static const CONNECTED:String = "connected";

		public function TodoistEvent(type:String)
		{

			super(type, bubbles, cancelable);
		}
	}
}
