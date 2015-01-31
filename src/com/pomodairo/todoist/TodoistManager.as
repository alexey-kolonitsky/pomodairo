package com.pomodairo.todoist
{
	import com.pomodairo.components.config.TodoistConfigPanel;
	import com.pomodairo.db.Storage;
	import com.pomodairo.twitter.*;
	import com.pomodairo.PomodoroEventDispatcher;
	import com.pomodairo.TaskManager;
	import com.pomodairo.components.config.TwitterConfigPanel;
	import com.pomodairo.events.ConfigurationUpdatedEvent;
	import com.pomodairo.events.PomodoroEvent;
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.oauth.OAuth;
	import com.swfjunkie.tweetr.oauth.events.OAuthEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.formatters.DateFormatter;
	
	public class TodoistManager
	{
		public static const STATUS_LOGIN:String = "logged in";
		public static const STATUS_LOGOFF:String = "logged off";
		public static const STATUS_WORKING:String = "is working on";	
		public static const STATUS_FREE:String = "is free";
		public static const STATUS_BREAK:String = "is on a break";
		
		// public static const SHORT_DATE_MASK:String	= "YYMMDD H:NN:SS";
		public static const SHORT_DATE_MASK:String	= "H:NN:SS";

		private var todoist:TodoistClient;
		private var dotodisEnabled:Boolean = false;
		
		private var oauth:OAuth;

		private var _dispatcher:PomodoroEventDispatcher;
		private var _db:Storage = Storage.instance;
		
		public function TodoistManager()
		{
			_dispatcher = PomodoroEventDispatcher.getInstance();
			_dispatcher.addEventListener(ConfigurationUpdatedEvent.UPDATED, onConfigurationChange);
		}
		
		private function onConfigurationChange(event:ConfigurationUpdatedEvent):void
		{
			switch (event.configElement.name)
			{
				case TodoistConfigPanel.ENABLED:
					dotodisEnabled = event.configElement.value == "true";
					break;
			}
		}
	}
}