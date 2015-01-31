package com.pomodairo.todoist
{
	public class TodoistState
	{
		/**
		 * Module created but not authorized. It is not ready to send any
		 * requests.
		 */
		public static const CREATED:String = "created";

		/**
		 * Module success in authorization
		 */
		public static const AUTHORIZED:String = "authorized";

		/**
		 * Module fail in authorization
		 */
		public static const UNAUTHORIZED:String = "unauthorized";

	}
}
