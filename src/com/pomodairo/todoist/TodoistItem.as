package com.pomodairo.todoist {
public class TodoistItem
{
	public var dueDate:String;
	public var userId:String;
	public var collapsed:String;
	public var inHistory:String;
	public var priority:String;
	public var itemOrder:String;
	public var content:String;
	public var indent:String;
	public var id:String;
	public var projectId:String;
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
