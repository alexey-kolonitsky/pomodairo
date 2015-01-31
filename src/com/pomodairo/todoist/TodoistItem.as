package com.pomodairo.todoist {
public class TodoistItem
{
	public var dueDate:String;
	public var userId:uint;
	public var collapsed:int;
	public var inHistory:int;
	public var priority:int;
	public var itemOrder:int;
	public var content:String;
	public var indent:uint;
	public var id:uint;
	public var projectId:uint;
	public var checked:Boolean;
	public var dateString:String;

	public function TodoistItem(init:Object)
	{
		if (init) {
			dueDate = init["due_date"];
			userId = init["user_id"];
			collapsed = init["collapsed"];
			inHistory = init["in_history"];
			priority = init["priority"];
			itemOrder = init["item_order"];
			content = init["content"];
			indent = init["indent"];
			projectId = init["project_id"];
			id = init["id"];
			checked = init["checked"];
			dateString = init["date_string"];
		}
	}
}
}
