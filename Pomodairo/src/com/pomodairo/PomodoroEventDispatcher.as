package com.pomodairo
{
import com.pomodairo.date.TimeSpan;
import com.pomodairo.events.PomodoroEvent;

import flash.events.Event;
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

		public function sendEvent(type:String,
								   pomodoro:Pomodoro,
								   value:String):void {
			var event:PomodoroEvent = new PomodoroEvent(type);
			event.pomodoro = pomodoro;
			event.value = value;
			PomodoroEventDispatcher.instance.dispatchEvent(event);
		}

		public function tick(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.TIMER_TICK, activeTask, null)
		}

		public function breakTick(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.BREAK_TICK, activeTask, null);
		}

		public function startTimer(activeTask:Pomodoro):void {

			sendEvent(PomodoroEvent.START_POMODORO, activeTask, null);
		}

		public function stopTimer(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.STOP_POMODORO, activeTask, null);
		}

		public function timeout(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.TIME_OUT, activeTask, null);
		}

		public function stopBreak(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.STOP_BREAK, activeTask, null);
		}

		public function startBreak(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.START_BREAK, activeTask, null);
		}

		public function pomodoroSelected(pomo:Pomodoro):void {
			sendEvent(PomodoroEvent.SELECTED, pomo, null);
		}
	}
}