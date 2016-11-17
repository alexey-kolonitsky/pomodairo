package com.pomodairo.components.config
{
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
	}
}
