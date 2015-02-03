package com.pomodairo.todoist
{
	import com.pomodairo.events.TodoistError;
	import com.pomodairo.events.TodoistError;
	import com.pomodairo.events.TodoistEvent;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	import mx.collections.ArrayCollection;

	public class TodoistClient extends EventDispatcher
	{
		private static const API_URL_PREFIX:String = "https://api.todoist.com/API";
		private static const API_HTTPS_PREFIX:String = "https://api.todoist.com/API";

		// Users
		private static const API_URL_LOGIN:String = "login";

		// Projects
		private static const API_URL_GET_PROJECTS:String = "getProjects";

		// Items
		private static const API_URL_ADD_ITEM:String = "addItem";
		private static const API_URL_UPDATE_ITEM:String = "updateItem";
		private static const API_URL_COMPLETE_ITEMS:String = "getCompletedItems";
		private static const API_URL_UNCOMPLETE:String = "getUncompletedItems";
		private static const API_URL_DELETE_ITEMS:String = "deleteItems";


		private static const ERROR_LOGIN:String = "LOGIN_ERROR";
		private static const ERROR_LOAD_PROJECT:String = "ERROR_PROJECT_NOT_FOUND";

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
		public var defaultProject:int;

		public var items:Vector.<TodoistItem>;

		[Bindable]
		public var projects:ArrayCollection;

		private var _isConnected:Boolean = false;

		public function TodoistClient()
		{
			items = new Vector.<TodoistItem>();
			projects = new ArrayCollection([]);
		}

		public function isConnected():Boolean
		{
			return _isConnected;
		}

		/**
		 * Send authorization request to Todoist API
		 *
		 * @param userName
		 * @param password
		 */
		public function connect(userName:String, password:String):void
		{
			trace("TodistClient connect " + userName + " / " + password);
			callSecure(API_URL_LOGIN, login_completeHandler, {email: userName, password: password});
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
			callSecure(API_URL_UNCOMPLETE, loadItems_completeHandler, {project_id: projectId, token: token});
		}

		public function getProjects():void
		{
			call(API_URL_GET_PROJECTS, loadProjects_completeHandler, {token: token});
		}


		//-------------------------------------------------------------------
		//
		//  Private
		//
		//-------------------------------------------------------------------

		private function createURLRequest(method:String, data:Object, useHTTPS:Boolean = false):URLRequest
		{
			var requst:URLRequest = new URLRequest(API_URL_PREFIX + "/" + method);
			requst.data = new URLVariables();
			for (var key:String in data)
				requst.data[key] = data[key];

			return requst;
		}

		private function callSecure(method:String, callback:Function, data:Object):void
		{
			var request:URLRequest = createURLRequest(method, data, true);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, callback);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function call(method:String, callback:Function, data:Object):void
		{
			var request:URLRequest = createURLRequest(method, data, false);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, callback);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.load(request);
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
			if (loader.data == ERROR_LOAD_PROJECT) {
				trace("TodoistClient login_completeHandler login failed");
				dispatchEvent(new TodoistError(TodoistError.ERROR_API, loader.data));
				return;
			}

			var data:Object = JSON.parse(String(loader.data));
			var ar:Array = data as Array;
			var n:int = ar.length;
			for (var i:int = 0; i < n; i++)
			{
				var item:Object = ar[i];
				items.push(new TodoistItem(item));
			}

			dispatchEvent(new TodoistEvent(TodoistEvent.ITEMS_CHANGED));
		}

		private function loadProjects_completeHandler(event:Event):void
		{
			trace("TodoistClient loadProjects_completeHandler ");

			var loader:URLLoader = event.currentTarget as URLLoader;
			var data:Object = JSON.parse(String(loader.data));
			var ar:Array = data as Array;

			var n:int = ar.length;
			for (var i:int = 0; i < n; i++)
			{
				var item:Object = ar[i];
				projects.addItem(new TodoistProject(item));
			}

			dispatchEvent(new TodoistEvent(TodoistEvent.PROJECTS_CHANGED));
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			dispatchEvent(new TodoistError(TodoistError.ERROR_API, event.text));
		}

		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			switch (event.status) {
				case 400:
					dispatchEvent(new TodoistError(TodoistError.ERROR_API, "Bad request"));
					break;
			}

		}
	}
}
