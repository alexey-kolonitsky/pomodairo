package com.pomodairo.events
{
	import flash.events.ErrorEvent;

	public class TodoistError extends ErrorEvent
	{
		public static const  ERROR_LOGIN:String = "LOGIN_ERROR";

		public function TodoistError(type:String, text:String="", id:int=0)
		{
			super(type, false, false, text, id);
		}
	}
}
