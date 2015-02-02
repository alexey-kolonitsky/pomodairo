package com.pomodairo.todoist
{
	import com.pomodairo.events.TodoistError;
	import com.pomodairo.events.TodoistError;
	import com.pomodairo.events.TodoistEvent;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	public class TodoistClient extends EventDispatcher
	{
		private static const API_URL_PREFIX:String = "https://api.todoist.com/API";

		// Users
		private static const API_URL_LOGIN:String = "login";

		// Projects
		private static const API_URL_GET_PROJECTS:String = "getProject";

		// Items
		private static const API_URL_ADD_ITEM:String = "addItem";
		private static const API_URL_UPDATE_ITEM:String = "updateItem";
		private static const API_URL_COMPLETE_ITEMS:String = "getCompletedItems";
		private static const API_URL_UNCOMPLETE:String = "getUncompletedItems";
		private static const API_URL_DELETE_ITEMS:String = "deleteItems";


		private static const ERROR_LOGIN:String = "LOGIN_ERROR";

		private var startPage:String;

		/**
		 * URL to user profile photo
		 */
		private var avatarSmall:String;

		/**
		 * Last used IP address
		 */
		private var lastUserIP:String;

		/**
		 * API token used to sign all requests. It loaded with successful
		 */
		private var apiToken:String;

		private var token:String;

		private var fullname:String;
		private var email:String;
		private var defaultProject:int;

		public var items:Vector.<TodoistItem>;

		private var _isConnected:Boolean = false;

		public function TodoistClient()
		{
			items = new Vector.<TodoistItem>();
		}

		public function isConnected():Boolean
		{
			return _isConnected;
		}

		/**
		 * Send authorization request to Todoist API
		 * @param userName
		 * @param password
		 */
		public function connect(userName:String, password:String):void
		{
			call(API_URL_LOGIN, login_completeHandler, {email: userName, password: password});
		}

		public function disconnect():void
		{
			this.startPage = "";
			this.avatarSmall = "";
			this.lastUserIP = "";
			this.apiToken = "";
			this.fullname = "";
			this.email = "";
			this.defaultProject = 0;
			this.token = "";

			items.length = 0;

			_isConnected = false;
		}

		public function addItem(item:TodoistItem):void
		{
			call(API_URL_ADD_ITEM, addItem_completeHandler, item);
		}

		public function updateItem(item:TodoistItem):void
		{
			call(API_URL_UPDATE_ITEM, updateItem_completeHandler, item);
		}

		public function deleteItems(item:TodoistItem):void
		{
			call(API_URL_DELETE_ITEMS, deleteItems_completeHandler, item);
		}

		public function getItems(project:int = -1):void
		{
			var projectId:int = project != -1 ? project : defaultProject;
			call(API_URL_UNCOMPLETE, loadItems_completeHandler, {project_id: project, token: token});
		}


		//-------------------------------------------------------------------
		//
		//  Private
		//
		//-------------------------------------------------------------------

		private function call(method:String, callback:Function, data:Object):void
		{
			var requst:URLRequest = new URLRequest(API_URL_PREFIX + "/" + method);
			requst.data = new URLVariables();
			for (var key:String in data)
				requst.data[key] = data[key];

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, callback);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(requst);
		}

		private function login_completeHandler(event:Event):void
		{
			var loader:URLLoader = event.currentTarget as URLLoader;
			var data:Object = JSON.parse(String(loader.data));

			if (data == ERROR_LOGIN) {
				trace("TodoistClient login_completeHandler login failed");
				dispatchEvent(new TodoistError(TodoistError.ERROR_LOGIN));
				return;
			}

			this.startPage = data.start_page;
			this.avatarSmall = data.svatar_small;
			this.lastUserIP = data.last_used_ip;
			this.apiToken = data.api_token;
			this.fullname = data.full_name;
			this.email = data.email;
			this.defaultProject = data.inbox_project;
			this.token = data.token;

			_isConnected = true;

			trace("TodoistClient login_completeHandler login successful");
			dispatchEvent(new TodoistEvent(TodoistEvent.CONNECTED));
		}


		//-------------------------------------------------------------------
		// Event Handlers
		//-------------------------------------------------------------------

		private function deleteItems_completeHandler(event:Event):void
		{
			trace("TodoistClient deleteItems_completeHandler ");
		}

		private function updateItem_completeHandler(event:Event):void
		{
			trace("TodoistClient updateItem_completeHandler ");
		}

		private function addItem_completeHandler(event:Event):void
		{
			trace("TodoistClient addItem_completeHandler ");
		}

		private function loadItems_completeHandler(event:Event):void
		{
			trace("TodoistClient loadItems_completeHandler ");

			var loader:URLLoader = event.currentTarget as URLLoader;
			var data:Object = JSON.parse(String(loader.data));
			var ar:Array = data as Array;

			var n:int = ar.length;
			for (var i:int = 0; i < n; i++)
			{
				var item:Object = ar[i];
				items.push(new TodoistItem(item));
			}
		}

		private function errorHandler(event:IOErrorEvent):void
		{

		}
	}
}
