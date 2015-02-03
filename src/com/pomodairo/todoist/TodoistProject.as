package com.pomodairo.todoist
{
	public class TodoistProject
	{
		public var id:int = -1;
		public var userId:int = -1;
		public var projectName:String;
		public var projectColor:uint = 0xFF0000;
		public var collapsed:Boolean = false;
		public var itemOrder:int = -1;
		public var indent:int = 4;
		public var casheCount:int = 0;

		public function TodoistProject(init:Object = null)
		{
			if (init) {
				this.userId = init["user_id"];
				this.projectName = init["name"];
				this.projectColor = init["color"];
				this.collapsed = init["collapsed"];
				this.itemOrder = init["item_order"];
				this.indent = init["indent"];
				this.casheCount = init["cache_count"];
				this.id = init["id"];
			}
		}

		public function toString():String
		{
			return projectName;
		}
	}
}
