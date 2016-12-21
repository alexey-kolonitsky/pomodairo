package com.pomodairo.core
{
import com.pomodairo.*;
import com.pomodairo.data.Pomodoro;
import com.pomodairo.date.TimeSpan;
import com.pomodairo.events.ConfigurationUpdatedEvent;
import com.pomodairo.events.PomodoroEvent;
import com.pomodairo.settings.ConfigItem;

import flash.events.Event;
import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * Singleton event dispatcher for pomodairo events
	 */
	public class PomodoroEventDispatcher extends EventDispatcher
	{
		private static var _instance:PomodoroEventDispatcher;
		
		public static function get instance():PomodoroEventDispatcher {
			if (_instance == null) {
				_instance = new PomodoroEventDispatcher();
			}
			return _instance;
		}

		public function PomodoroEventDispatcher() {
			super(null);
		}

		public function sendEvent(type:String, pomodoro:Pomodoro = null, value:String = null):void {
			var event:PomodoroEvent = new PomodoroEvent(type);
			event.pomodoro = pomodoro;
			event.value = value;
			dispatchEvent(event);
		}

		public function tick(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.TIMER_TICK, activeTask, null)
		}

		public function breakTick(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.BREAK_TICK, activeTask, null);
		}

		public function timeout(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.TIME_OUT, activeTask, null);
		}

		public function startBreak(activeTask:Pomodoro):void {
			sendEvent(PomodoroEvent.START_BREAK, activeTask, null);
		}

		public function sendConfigItemUpdateEvent(item:ConfigItem):void {
			var event:ConfigurationUpdatedEvent = new ConfigurationUpdatedEvent(ConfigurationUpdatedEvent.UPDATED, item.name, item.userValue);
			dispatchEvent(event);
		}
	}
}