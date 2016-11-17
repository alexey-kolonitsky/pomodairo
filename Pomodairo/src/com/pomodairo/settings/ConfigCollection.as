/**
 * Created by akalanitski on 16.11.2016.
 */
package com.pomodairo.settings {

	import flash.events.EventDispatcher;

	public class ConfigCollection extends EventDispatcher {

		private var _source:Vector.<ConfigItem>;

		public function ConfigCollection() {
			_source = new Vector.<ConfigItem>();
		}

		public function getItem(key:String):ConfigItem {
			if (key == null || key == "")
				throw new ArgumentError("Key must be not null.");

			for each (var item:ConfigItem in _source)
				if (item.name == key)
					return item;
			return null;
		}

		public function addItem(item:ConfigItem):void {
			_source.push(item);
		}

		public function getString(key:String):String {
			var item:ConfigItem = getItem(key);
			if (item != null) {
				return String(item.userValue || item.defaultValue);
			}
			return null;
		}

		public function setString(name:String, value:String, create:Boolean = false):void {
			var item:ConfigItem = getItem(name);
			if (item != null) {
				item.userValue = value;
			} else if (create) {
				item = new ConfigItem();
				item.name = name;
				item.userValue = value;
				_source.push(item);
			}
		}

	}
}
