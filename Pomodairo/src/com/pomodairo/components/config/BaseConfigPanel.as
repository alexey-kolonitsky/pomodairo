package com.pomodairo.components.config
{
import com.pomodairo.core.PomodoroEventDispatcher;
import com.pomodairo.core.Storage;
import com.pomodairo.events.ConfigurationUpdatedEvent;
import com.pomodairo.settings.ConfigItemName;

import mx.containers.Canvas;
import mx.managers.PopUpManager;

	public class BaseConfigPanel extends Canvas
	{
		public function BaseConfigPanel()
		{
			setStyle("backgroundColor", 0x313131);
		}

		public function populate():void
		{

		}

		public function notifyConfiguration():void
		{

		}

		public function exit():void
        {
			PopUpManager.removePopUp(this);
        }

		public function save():void {

		}

		protected function dispatchConfigChangeEvent(name:String, value:String):void {
			var event:ConfigurationUpdatedEvent = new ConfigurationUpdatedEvent(ConfigurationUpdatedEvent.UPDATED, name, value);
			PomodoroEventDispatcher.instance.dispatchEvent(event);
		}

		protected function saveConfigItem(key:String, value:String):void {
			Storage.instance.updateConfig(key, value);
		}
	}
}
