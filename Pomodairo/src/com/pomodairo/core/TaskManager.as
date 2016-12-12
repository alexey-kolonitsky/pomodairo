package com.pomodairo.core
{
import com.pomodairo.*;
	import com.pomodairo.core.Storage;
import com.pomodairo.data.Pomodoro;
import com.pomodairo.events.PomodoroEvent;
import com.pomodairo.settings.ConfigManager;

import mx.collections.ArrayCollection;
	
	public class TaskManager
	{
		public static const DEFAULT_SETTINGS_FILE_PATH:String = "assets/settings.properties";

		public static var instance:TaskManager = new TaskManager();
		
		[Bindable]
		public var activeTask:Pomodoro; 		

		private var db:Storage = Storage.instance;
		
		private var openTasks:ArrayCollection = new ArrayCollection();

		private var configManager:ConfigManager = ConfigManager.instance;

		private var eventDispatcher:PomodoroEventDispatcher;

		public function TaskManager() {
			configManager.defaultSettingsFilePath = DEFAULT_SETTINGS_FILE_PATH;
			configManager.initialize();

			eventDispatcher = PomodoroEventDispatcher.instance;

			db.initAndOpenDatabase();
			openTasks = db.getOpenPomodoros();
		}

		public function findNextTask():void {
			var result:Boolean = nextTask();
			if (result == false) {
				eventDispatcher.sendEvent(PomodoroEvent.LIST_EMPTY, null, null);
			}
		}
		
		public function nextTask():Boolean {
			refresh();
			
			if(openTasks.length == 0) {
				activeTask = null;
				eventDispatcher.sendEvent(PomodoroEvent.LIST_EMPTY);
			}

			var currentIndex:int = -1;
			if (activeTask)
				currentIndex = getItemIndex(activeTask);

			// End of list reached. Select first element.
			if(currentIndex >= (openTasks.length -1) || currentIndex == -1) {
				activeTask = Pomodoro(openTasks.getItemAt(0));
			}
			// Select next element in list.
			else {
				activeTask = Pomodoro(openTasks.getItemAt(currentIndex+1));
			}
			trace("Next task is '" + activeTask.name + "'.");
			eventDispatcher.sendEvent(PomodoroEvent.NEXT_TASK_SELECTED, activeTask, null);
			return true;
		}

		public function setActive(task:Pomodoro):void {
			refresh();
			
			if(getItemIndex(task) >= 0) {
				activeTask = task;
				trace("Activated task '"+task.name+"'.");
			}
			else {
				trace("Task '"+task.name+"' is not in list of open tasks.");
				var event:PomodoroEvent = new PomodoroEvent(PomodoroEvent.LIST_EMPTY);
				PomodoroEventDispatcher.instance.dispatchEvent(event);
			}
		}
		
		public function hasMoreTasks():Boolean {
			if(openTasks.length > 1) {
				return true;
			}
			return false;
		}
		
		private function refresh():void {
			// TODO: Call refresh method.
			openTasks = db.getOpenPomodoros();
		}
		
		private function getItemIndex(item:Pomodoro):int {
			for(var i:int; i < openTasks.length; i++) {
				var curItem:Pomodoro = Pomodoro(openTasks.getItemAt(i));
				if(curItem.created.time == item.created.time) {
					return i;	
				}
			}
			return -1;
		}

	}
}