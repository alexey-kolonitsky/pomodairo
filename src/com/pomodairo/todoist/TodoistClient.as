package com.pomodairo.todoist
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	public class TodoistClient
	{
		private static const API_URL:String = "https://api.todoist.com/API";

		private var startPage:String;
		private var avatarSmall:String;
		private var lastUserIP:String;
		private var apiToken:String;
		private var fullname:String;
		private var email:String;
		private var inboxProject:String;
		private var token:String;

		public function TodoistClient()
		{
			var requst:URLRequest = new URLRequest(API_URL + "/login");
			requst.data = new URLVariables();
			requst.data.email = "alexey@kolonitsky.org";
			requst.data.password = "NanaTheBest1";
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loader_completeHandler);

			loader.load(requst);
		}

		private function loader_completeHandler(event:Event):void
		{
			var loader:URLLoader = event.currentTarget as URLLoader;
			var data:Object = loader.data;

			this.startPage = data.start_page;
			this.avatarSmall = data.svatar_small;
			this.lastUserIP = data.last_used_ip;
			this.apiToken = data.api_token;
			this.fullname = data.full_name;
			this.email = data.email;
			this.inboxProject = data.inbox_project;
			this.token = data.token;

			trace("TodoistClient loader_completeHandler ");
		}

		public function addItem(content:String):void
		{

		}

		public function updateItem():void
		{

		}

		public function deleteItems():void
		{

		}

		public function getItem():void
		{

		}
	}
}
