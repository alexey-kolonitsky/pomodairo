package com.pomodairo.events
{
	import flash.events.Event;

	public class TodoistEvent extends Event
	{
		public static const CONNECTED:String = "todoist.connected";
		public static const PROJECTS_CHANGED:String = "todoist.project_chagned";
		public static const ITEMS_CHANGED:String = "todoist.items_changed";

		public function TodoistEvent(type:String)
		{

			super(type, bubbles, cancelable);
		}
	}
}
