package com.pomodairo
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * Singleton event dispatcher for pomodairo events
	 */
	public class PomodoroEventDispatcher extends EventDispatcher
	{
		private static var _instance:PomodoroEventDispatcher;
		
		public function PomodoroEventDispatcher()
		{
			super(null);
		}
		
		public static function get instance():PomodoroEventDispatcher {
			if (_instance == null) {
				_instance = new PomodoroEventDispatcher();
			}
			return _instance;
		}
		
	}
}