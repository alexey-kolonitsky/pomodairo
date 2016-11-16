package com.pomodairo.events
{
	import flash.events.Event;

	public class TwitterPomodoroEvent extends Event
	{
		public static var NEW:String = "pomodoro twitter update";
		
		public var twitterStatus:String;
		
		public var value:String;
		
		public function TwitterPomodoroEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}